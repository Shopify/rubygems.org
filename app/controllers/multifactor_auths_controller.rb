class MultifactorAuthsController < ApplicationController
  include MfaExpiryMethods

  before_action :redirect_to_signin, unless: :signed_in?
  before_action :require_otp_disabled, only: %i[new create]
  before_action :require_mfa_enabled, only: %i[update destroy]
  before_action :seed_and_expire, only: :create
  helper_method :issuer

  def new
    @seed = ROTP::Base32.random_base32
    session[:otp_seed] = @seed
    session[:otp_seed_expire] = Gemcutter::MFA_KEY_EXPIRY.from_now.utc.to_i
    text = ROTP::TOTP.new(@seed, issuer: issuer).provisioning_uri(current_user.email)
    @qrcode_svg = RQRCode::QRCode.new(text, level: :l).as_svg(module_size: 6)
  end

  def create
    current_user.verify_and_enable_otp!(@seed, :ui_and_api, otp_param, @expire)
    if current_user.errors.any?
      flash[:error] = current_user.errors[:base].join
      redirect_to edit_settings_url
    else
      flash.now[:success] = t(".success")
      @continue_path = session.fetch("mfa_redirect_uri", edit_settings_path)
      session.delete("mfa_redirect_uri")
      render :recovery
    end
  end

  def destroy
    if current_user.ui_otp_verified?(otp_param)
      flash[:success] = t("multifactor_auths.destroy.success")
      current_user.disable_otp!
      redirect_to session.fetch("mfa_redirect_uri", edit_settings_path)
      session.delete("mfa_redirect_uri")
    else
      flash[:error] = t("multifactor_auths.incorrect_otp")
      redirect_to edit_settings_path
    end
  end

  def update
    session[:level] = level_param
    @user = current_user # Need to set this for the mfa_prompt template as it relies on having an @user

    setup_mfa_authentication
    setup_webauthn_authentication

    create_new_mfa_expiry

    render template: "multifactor_auths/mfa_prompt"
  end

  def mfa_update
    if mfa_update_conditions_met?
      update_level
    elsif !session_active?
      login_failure(t("multifactor_auths.session_expired"))
    else
      login_failure(t("multifactor_auths.incorrect_otp"))
    end
  end

  def webauthn_update
    @challenge = session.dig(:webauthn_authentication, "challenge")

    if params[:credentials].blank?
      login_failure(t("credentials_required"))
      return
    elsif !session_active?
      login_failure(t("multifactor_auths.session_expired"))
      return
    end

    @credential = WebAuthn::Credential.from_get(params[:credentials])

    @webauthn_credential = current_user.webauthn_credentials.find_by(
      external_id: @credential.id
    )

    @credential.verify(
      @challenge,
      public_key: @webauthn_credential.public_key,
      sign_count: @webauthn_credential.sign_count
    )

    @webauthn_credential.update!(sign_count: @credential.sign_count)

    update_level
  rescue WebAuthn::Error => e
    login_failure(e.message)
  end

  private

  def update_level
    handle_new_level_param
    redirect_to session.fetch("mfa_redirect_uri", edit_settings_path)
    session.delete("mfa_redirect_uri")
    session.delete(:level)
  end

  def mfa_update_conditions_met?
    current_user.mfa_enabled? && current_user.ui_otp_verified?(params[:otp]) && session_active?
  end


  def otp_param
    params.permit(:otp).fetch(:otp, "")
  end

  def level_param
    params.permit(:level).fetch(:level, "")
  end

  def issuer
    request.host || "rubygems.org"
  end

  def require_otp_disabled
    return unless current_user.otp_enabled?
    flash[:error] = t("multifactor_auths.require_mfa_disabled")
    redirect_to edit_settings_path
  end

  def require_mfa_enabled
    return if current_user.mfa_enabled?
    flash[:error] = t("multifactor_auths.require_mfa_enabled")
    redirect_to edit_settings_path
  end

  def seed_and_expire
    @seed = session[:otp_seed]
    @expire = Time.at(session[:otp_seed_expire] || 0).utc
    %i[otp_seed otp_seed_expire].each do |key|
      session.delete(key)
    end
  end

  # rubocop:disable Rails/ActionControllerFlashBeforeRender
  def handle_new_level_param
    case session[:level]
    when "disabled"
      flash[:success] = t("multifactor_auths.destroy.success")
      current_user.disable_otp!
    when "ui_only"
      flash[:error] = t("multifactor_auths.ui_only_warning")
    else
      flash[:error] = t("multifactor_auths.update.success")
      current_user.update!(mfa_level: session[:level])
    end
  end
  # rubocop:enable Rails/ActionControllerFlashBeforeRender

  def setup_mfa_authentication
    return if current_user.mfa_disabled?
    @form_mfa_url = mfa_update_multifactor_auth_url(token: current_user.confirmation_token)
  end

  def setup_webauthn_authentication
    return if current_user.webauthn_credentials.none?

    @form_webauthn_url = webauthn_update_multifactor_auth_url(token: current_user.confirmation_token)

    @webauthn_options = current_user.webauthn_options_for_get

    session[:webauthn_authentication] = {
      "challenge" => @webauthn_options.challenge
    }
  end
end

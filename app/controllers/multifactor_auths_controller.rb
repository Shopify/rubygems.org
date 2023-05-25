class MultifactorAuthsController < ApplicationController
  include MfaExpiryMethods
  include WebauthnVerifiable

  before_action :redirect_to_signin, unless: :signed_in?
  before_action :require_totp_disabled, only: %i[new create]
  before_action :require_mfa_enabled, only: %i[update destroy]
  before_action :seed_and_expire, only: :create
  before_action :verify_session_expiration, only: %i[mfa_update webauthn_update]
  after_action :delete_mfa_level_update_session_variables, only: %i[mfa_update webauthn_update]
  helper_method :issuer

  def new
    @seed = ROTP::Base32.random_base32
    session[:mfa_seed] = @seed
    session[:mfa_seed_expire] = Gemcutter::MFA_KEY_EXPIRY.from_now.utc.to_i
    text = ROTP::TOTP.new(@seed, issuer: issuer).provisioning_uri(current_user.email)
    @qrcode_svg = RQRCode::QRCode.new(text, level: :l).as_svg(module_size: 6)
  end

  def create
    current_user.verify_and_enable_totp!(@seed, :ui_and_api, otp_param, @expire)
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
    if current_user.ui_mfa_verified?(otp_param)
      flash[:success] = t("multifactor_auths.destroy.success")
      current_user.disable_totp!
      redirect_to session.fetch("mfa_redirect_uri", edit_settings_path)
      session.delete("mfa_redirect_uri")
    else
      flash[:error] = t("multifactor_auths.incorrect_otp")
      redirect_to edit_settings_path
    end
  end

  def update
    unless valid_mfa_level?
      redirect_to edit_settings_path, flash: { error: t(".invalid_level") }
      return
    end

    session[:level] = level_param
    @user = current_user

    setup_mfa_authentication
    setup_webauthn_authentication

    create_new_mfa_expiry

    render template: "multifactor_auths/mfa_prompt"
  end

  def mfa_update
    if mfa_update_conditions_met?
      update_level_and_redirect
    else
      redirect_to edit_settings_path, flash: { error: t("multifactor_auths.incorrect_otp") }
    end
  end

  def webauthn_update
    unless current_user.webauthn_enabled?
      redirect_to edit_settings_path, flash: { error: t("multifactor_auths.no_webauthn_devices") }
      return
    end

    if webauthn_credential_verified?
      update_level_and_redirect
    else
      redirect_to edit_settings_path, flash: { error: @webauthn_error }
    end
  end

  private

  def otp_param
    params.permit(:otp).fetch(:otp, "")
  end

  def level_param
    params.permit(:level).fetch(:level, "")
  end

  def issuer
    request.host || "rubygems.org"
  end

  def require_totp_disabled
    return unless current_user.totp_enabled?
    flash[:error] = t("multifactor_auths.require_mfa_disabled")
    redirect_to edit_settings_path
  end

  def require_mfa_enabled
    return if current_user.mfa_enabled?
    flash[:error] = t("multifactor_auths.require_mfa_enabled")
    redirect_to edit_settings_path
  end

  def seed_and_expire
    @seed = session[:mfa_seed]
    @expire = Time.at(session[:mfa_seed_expire] || 0).utc
    %i[mfa_seed mfa_seed_expire].each do |key|
      session.delete(key)
    end
  end

  def verify_session_expiration
    return if session_active?

    delete_mfa_level_update_session_variables
    redirect_to edit_settings_path, flash: { error: t("multifactor_auths.session_expired") }
  end

  def delete_mfa_level_update_session_variables
    session.delete(:level)
    session.delete("mfa_redirect_uri")
    delete_mfa_expiry_session
  end

  # rubocop:disable Rails/ActionControllerFlashBeforeRender
  def handle_new_level_param
    case session[:level]
    when "disabled"
      flash[:success] = t("multifactor_auths.destroy.success")
      current_user.disable_totp!
    when "ui_only"
      flash[:error] = t("multifactor_auths.ui_only_warning")
    else
      flash[:error] = t("multifactor_auths.update.success")
      current_user.update!(mfa_level: session[:level])
    end
  end
  # rubocop:enable Rails/ActionControllerFlashBeforeRender

  def setup_mfa_authentication
    return if current_user.totp_disabled?
    @form_mfa_url = mfa_update_multifactor_auth_url(token: current_user.confirmation_token)
  end

  def setup_webauthn_authentication
    return if current_user.webauthn_disabled?

    @webauthn_verification_url = webauthn_update_multifactor_auth_url(token: current_user.confirmation_token)

    @webauthn_options = current_user.webauthn_options_for_get

    session[:webauthn_authentication] = {
      "challenge" => @webauthn_options.challenge
    }
  end

  def update_level_and_redirect
    handle_new_level_param
    redirect_to session.fetch("mfa_redirect_uri", edit_settings_path)
  end

  def valid_mfa_level?
    %w[ui_only ui_and_api].include?(level_param)
  end

  def mfa_update_conditions_met?
    current_user.mfa_enabled? && current_user.ui_mfa_verified?(params[:otp]) && session_active?
  end
end

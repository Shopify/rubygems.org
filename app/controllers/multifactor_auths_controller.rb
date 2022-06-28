class MultifactorAuthsController < ApplicationController
  before_action :redirect_to_signin, unless: :signed_in?
  before_action :require_mfa_disabled, only: %i[new create]
  before_action :require_mfa_enabled, only: :update
  before_action :seed_and_expire, only: %i[create submit_replace]
  before_action :redirect_to_verify, unless: :mfa_verification_session_active?, only: %i[replace submit_replace]

  helper_method :issuer

  def new
    mfa_setup
  end

  def create
    check_new_mfa
  end

  def update
    if current_user.otp_verified?(otp_param)
      handle_new_level_param
    else
      flash[:error] = t("multifactor_auths.incorrect_otp")
    end
    redirect_to edit_settings_url
  end

  def replace
    mfa_setup
  end

  def submit_replace
    check_new_mfa
  end

  def verify
  end

  def submit_verify
    if current_user.otp_verified?(otp_param)
      session[:mfa_verified_user] = current_user.id
      session[:mfa_verification]  = Time.current + Gemcutter::MFA_VERIFICATION_EXPIRY
      redirect_to replace_multifactor_auth_path
    else
      flash[:error] = t("multifactor_auths.incorrect_otp")
      redirect_to verify_multifactor_auth_path
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

  def require_mfa_disabled
    return unless current_user.mfa_enabled?
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

  def handle_new_level_param
    case level_param
    when "disabled"
      flash[:success] = t("multifactor_auths.destroy.success")
      current_user.disable_mfa!
    when "ui_only"
      flash[:error] = t("multifactor_auths.ui_only_warning")
    else
      flash[:error] = t(".success")
      current_user.update!(mfa_level: level_param)
    end
  end

  def mfa_setup
    @seed = ROTP::Base32.random_base32
    session[:mfa_seed] = @seed
    session[:mfa_seed_expire] = Gemcutter::MFA_KEY_EXPIRY.from_now.utc.to_i
    text = ROTP::TOTP.new(@seed, issuer: issuer).provisioning_uri(current_user.email)
    @qrcode_svg = RQRCode::QRCode.new(text, level: :l).as_svg(module_size: 6)
    @key_chunk_length = 4
  end

  def check_new_mfa
    remove_session
    current_user.verify_and_enable_mfa!(@seed, :ui_and_api, otp_param, @expire)
    if current_user.errors.any?
      flash[:error] = current_user.errors[:base].join
      redirect_to edit_settings_path
    else
      flash[:success] = t(".success")
      render :recovery
    end
  end

  def redirect_to_verify
    flash[:error] = if session[:mfa_verification]
                      t("multifactor_auths.replace.timeout")
                    else
                      t("multifactor_auths.replace.verify")
                    end
    remove_session
    redirect_to verify_multifactor_auth_path
  end

  def remove_session
    session[:mfa_verified_user] = nil
    session[:mfa_verification] = nil
  end
end

class WebauthnCredentialsController < ApplicationController
  before_action :redirect_to_signin, unless: :signed_in?

  def create
    @create_options = current_user.webauthn_options_for_create

    session[:webauthn_registration] = { "challenge" => @create_options.challenge }

    render json: @create_options
  end

  def callback
    webauthn_credential = build_webauthn_credential

    if webauthn_credential.save
      set_mfa_level_create
      if current_user.otp_disabled? && current_user.count_webauthn_credentials == 1
        current_user.mfa_recovery_codes = Array.new(10).map { SecureRandom.hex(6) }
        current_user.save!(validate: false)

        redirect_to recovery_multifactor_auth_path
      else
        redirect_to edit_settings_path
      end
    else
      message = webauthn_credential.errors.full_messages.to_sentence
      render json: { message: message }, status: :unprocessable_entity
    end
  rescue WebAuthn::Error => e
    render json: { message: e.message }, status: :unprocessable_entity
  ensure
    session.delete("webauthn_registration")
  end

  def destroy
    webauthn_credential = current_user.webauthn_credentials.find(params[:id])
    if webauthn_credential.destroy
      set_mfa_level_destroy

      flash[:notice] = t(".webauthn_credential.confirm_delete")
    else
      flash[:error] = webauthn_credential.errors.full_messages.to_sentence
    end

    redirect_to edit_settings_path
  end

  private

  def set_mfa_level_create
    if current_user.webauthn_credentials.count == 1 && !current_user.otp_enabled?
      current_user.update!(mfa_level: "ui_and_api")
    end
  end

  def set_mfa_level_destroy
    if current_user.webauthn_credentials.empty? && !current_user.otp_enabled?
      current_user.update!(mfa_level: "disabled", mfa_recovery_codes: [])
    end
  end

  def webauthn_credential_params
    params.require(:webauthn_credential).permit(:nickname)
  end

  def build_webauthn_credential
    credential = WebAuthn::Credential.from_create(params.require(:credentials))
    credential.verify(session.dig(:webauthn_registration, "challenge").to_s)

    current_user.webauthn_credentials.build(
      webauthn_credential_params.merge(
        external_id: credential.id,
        public_key: credential.public_key,
        sign_count: credential.sign_count
      )
    )
  end
end

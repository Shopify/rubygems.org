class WebauthnCredentialsController < ApplicationController
  before_action :redirect_to_signin, unless: :signed_in?

  def create
    @create_options = current_user.webauthn_options_for_create

    session[:webauthn_registration] = { challenge: @create_options.challenge }

    render json: @create_options
  end

  def callback
    credential = WebAuthn::Credential.from_create(params.require(:credentials))
    credential.verify(session.dig(:webauthn_registration, "challenge"))

    webauthn_credential = current_user.webauthn_credentials.build(
      webauthn_credential_params.merge(
        external_id: credential.id,
        public_key: credential.public_key,
        sign_count: credential.sign_count
      )
    )

    if webauthn_credential.save
      if current_user.webauthn_credentials.one? && !current_user.mfa_enabled?
        current_user.enable_recovery_codes!
        render json: {
          recovery_html: render_to_string(
            "webauthn_credentials/recovery",
            layout: false,
            formats: :html
          )
        }
      else
        render json: { location: edit_settings_path }
      end
    else
      render(
        json: {
          message: webauthn_credential.errors.full_messages.to_sentence
        },
        status: :unprocessable_entity
      )
    end
  rescue WebAuthn::Error => e
    render json: { message: e.message }, status: :unprocessable_entity
  ensure
    session.delete("webauthn_registration")
  end

  def destroy
    current_user.webauthn_credentials.find(params[:id]).destroy!

    if current_user.webauthn_credentials.none? && current_user.mfa_disabled?
      current_user.update!(mfa_recovery_codes: [])
    end

    redirect_to edit_settings_path
  end

  private

  def webauthn_credential_params
    params.require(:webauthn_credential).permit(:nickname)
  end
end

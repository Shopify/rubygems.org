class WebauthnCredentialsController < ApplicationController
  before_action :redirect_to_signin, unless: :signed_in?

  def index
    @webauthn_credentials = current_user.webauthn_credentials
  end

  def show
    @webauthn_credential = current_user.webauthn_credentials.find(params[:id])
  end

  def new
    @webauthn_credential = current_user.webauthn_credentials.build
  end

  def create
    @create_options = current_user.webauthn_options_for_create

    session[:current_registration] = { challenge: @create_options.challenge }

    render json: @create_options
  end

  def callback
    credential = WebAuthn::Credential.from_create(params.require(:credentials))
    credential.verify(session.dig(:current_registration, "challenge"))

    webauthn_credential = current_user.webauthn_credentials.build(
      webauthn_credential_params.merge(
        external_id: credential.id,
        public_key: credential.public_key,
        sign_count: credential.sign_count
      )
    )

    if webauthn_credential.save
      render json: { message: "OK" }, status: :ok
    else
      render(
        json: { message: webauthn_credential.errors.full_messages.to_sentence },
        status: :unprocessable_entity
      )
    end
  rescue WebAuthn::Error => e
    render json: { message: e.message }, status: :unprocessable_entity
  ensure
    session.delete("current_registration")
  end

  def destroy
    current_user.webauthn_credentials.find(params[:id]).destroy!
    redirect_to webauthn_credentials_path
  end

  private

  def webauthn_credential_params
    params.require(:webauthn_credential).permit(:nickname)
  end
end

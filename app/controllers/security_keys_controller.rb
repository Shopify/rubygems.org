class SecurityKeysController < ApplicationController
  before_action :redirect_to_signin, unless: :signed_in?

  def index
    @security_keys = current_user.security_keys
  end

  def show
    @security_key = current_user.security_keys.find(params[:id])
  end

  def new
    @security_key = current_user.security_keys.build
  end

  def create
    @create_options = current_user.webauthn_options_for_create

    session[:current_registration] = { challenge: @create_options.challenge }

    render json: @create_options
  end

  def callback
    webauthn_credential = WebAuthn::Credential.from_create(
      params.require(:credentials)
    )
    webauthn_credential.verify(session.dig(:current_registration, "challenge"))

    security_key = current_user.security_keys.build(
      security_key_params.merge(
        external_id: webauthn_credential.id,
        public_key: webauthn_credential.public_key,
        sign_count: webauthn_credential.sign_count
      )
    )

    if security_key.save
      render json: { message: "OK" }, status: :ok
    else
      render(
        json: { message: security_key.errors.full_messages.to_sentence },
        status: :unprocessable_entity
      )
    end
  rescue WebAuthn::Error => e
    render json: { message: e.message }, status: :unprocessable_entity
  ensure
    session.delete("current_registration")
  end

  def destroy
    current_user.security_keys.find(params[:id]).destroy!
    redirect_to security_keys_path
  end

  private

  def security_key_params
    params.require(:security_key).permit(:nickname)
  end
end

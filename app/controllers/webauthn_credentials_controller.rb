class WebauthnCredentialsController < ApplicationController
  before_action :redirect_to_signin, unless: :signed_in?, except: [:prompt]
  before_action :set_user, only: :prompt

  def create
    @create_options = current_user.webauthn_options_for_create

    session[:webauthn_registration] = { "challenge" => @create_options.challenge }

    render json: @create_options
  end

  def callback
    webauthn_credential = build_webauthn_credential

    if webauthn_credential.save
      redirect_to edit_settings_path
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

    redirect_to edit_settings_path
  end

  def prompt
    # return if @user.webauthn_credentials.none?
    @webauthn_options = @user.webauthn_options_for_get

    session[:webauthn_authentication] = {
      "challenge" => @webauthn_options.challenge,
      "user" => @user.id,
      "redirect_uri" => params[:redirect_uri]
    }
  end

  def verify
    @user = User.find(session.dig(:webauthn_authentication, "user"))
    @challenge = session.dig(:webauthn_authentication, "challenge")

    if params[:credentials].blank?
      render_prompt("Credentials required", :unauthorized)
      return
    end

    @credential = WebAuthn::Credential.from_get(params[:credentials])

    @webauthn_credential = @user.webauthn_credentials.find_by(
      external_id: @credential.id
    )

    @credential.verify(
      @challenge,
      public_key: @webauthn_credential.public_key,
      sign_count: @webauthn_credential.sign_count
    )

    @webauthn_credential.update!(sign_count: @credential.sign_count)
    @user.webauthn_otp = SecureRandom.hex(6)
    @user.webauthn_otp_expires_at = 1.minute.from_now
    @user.save!(validate: false)

    uri = session.dig(:webauthn_authentication, "redirect_uri")
    if uri
      redirect_to "#{uri}?code=#{@user.webauthn_otp}"
    else
      render_prompt("success", :ok)
    end
  rescue WebAuthn::Error => e
    render_prompt(e.message, :unauthorized)
  ensure
    session.delete(:webauthn_authentication)
  end

  private

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

  def set_user
    @user = User.find_by(webauthn_token: webauthn_token_param)
    render_not_found if @user.webauthn_token_expires_at < Time.now
  end

  def webauthn_token_param
    params.permit(:webauthn_token).require(:webauthn_token)
  end

  def render_prompt(message, status)
    respond_to do |format|
      format.json do
        render json: { message: message }, status: :unauthorized
      end

      format.html do
        flash.now.notice = message
        render template: "webauthn_credentials/prompt", status: status
      end
    end
  end
end

class Api::V1::WebauthnController < Api::BaseController
  before_action :authenticate_with_credentials

  def create
    token = @user.refresh_webauthn_token
    render plain: webauthn_prompt_url(webauthn_token: token)
  end

  def status
    webauthn_token = params[:token] # should use strong params
    user = User.find_by(webauthn_token: webauthn_token)

    if user.nil?
      render plain: "token invalid", status: :forbidden
    elsif user.webauthn_otp_expires_at < Time.now
      render plain: "otp has expired", status: :forbidden
    else
      render plain: user.webauthn_otp
    end
  end

  private

  def authenticate_with_credentials
    params_key = request.headers["Authorization"] || ""
    hashed_key = Digest::SHA256.hexdigest(params_key)
    api_key   = ApiKey.find_by_hashed_key(hashed_key)

    @user = if api_key
      api_key.user
    else
      authenticate_or_request_with_http_basic do |username, password|
        User.authenticate(username, password)
      end
    end
  end
end

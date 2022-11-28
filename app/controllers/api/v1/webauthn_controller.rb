class Api::V1::WebauthnController < Api::BaseController
  before_action :authenticate_with_credentials

  def create
    token = @user.refresh_webauthn_token
    render plain: webauthn_prompt_url(webauthn_token: token)
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

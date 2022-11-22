class Api::V1::ApiKeysController < Api::BaseController
  include ApiKeyable

  def show
    authenticate_with_mfa_and_create_key(legacy_key_defaults)
  end

  def create
    authenticate_with_mfa_and_create_key(api_key_create_params)
  end

  def update
    authenticate_or_request_with_http_basic do |username, password|
      # strip username mainly to remove null bytes
      user = User.authenticate(username.strip, password)

      check_mfa(user) do
        api_key = user.api_keys.find_by!(hashed_key: hashed_key(params[:api_key]))

        if api_key.update(api_key_update_params)
          respond_with "Scopes for the API key #{api_key.name} updated"
        else
          errors = api_key.errors.full_messages.to_sentence
          respond_with "Failed to update scopes for the API key #{api_key.name}: #{errors}", status: :unprocessable_entity
        end
      end
    end
  end

  private

  def authenticate_with_mfa_and_create_key(api_key_params)
    authenticate_or_request_with_http_basic do |username, password|
      # strip username mainly to remove null bytes
      user = User.authenticate(username.strip, password)

      check_mfa(user) do
        key = generate_unique_rubygems_key
        api_key = user.api_keys.build(api_key_params.merge(hashed_key: hashed_key(key)))

        if api_key.save
          Mailer.delay.api_key_created(api_key.id)
          respond_with key
        else
          respond_with api_key.errors.full_messages.to_sentence, status: :unprocessable_entity
        end
      end
    end
  end

  def check_mfa(user)
    return unless user
    if user.mfa_gem_signin_authorized?(otp)
      return render_forbidden(mfa_level_error_message(user)) if user.mfa_required?

      yield
    elsif user.mfa_enabled?
      render plain: otp_error_message, status: :unauthorized
    end
  end

  def mfa_level_error_message(user)
    if user.mfa_disabled?
      error_message("set up multi-factor authentication at https://rubygems.org/multifactor_auth/new.")
    elsif user.mfa_ui_only?
      error_message("change your MFA level to 'UI and gem signin' or 'UI and API' at https://rubygems.org/settings/edit.")
    end
  end

  def otp_error_message
    if otp.present?
      t(:otp_incorrect)
    else
      t(:otp_missing)
    end
  end

  def error_message(required_action)
    error = <<~ERROR.chomp
      [ERROR] For protection of your account and your gems, you are required to #{required_action}

      Please read our blog post for more details (https://blog.rubygems.org/2022/08/15/requiring-mfa-on-popular-gems.html).
    ERROR
  end

  def save_and_respond(api_key, key)
    if api_key.save
      Mailer.delay.api_key_created(api_key.id)
      respond_with key
    else
      respond_with api_key.errors.full_messages.to_sentence, status: :unprocessable_entity
    end
  end

  def respond_with(msg, status: :ok)
    respond_to do |format|
      format.any(:all) { render plain: msg, status: status }
      format.json { render json: { rubygems_api_key: msg, status: status } }
      format.yaml { render plain: { rubygems_api_key: msg, status: status }.to_yaml }
    end
  end

  def otp
    request.headers["HTTP_OTP"]
  end

  def api_key_create_params
    params.permit(:name, *ApiKey::API_SCOPES, :mfa)
  end

  def api_key_update_params
    params.permit(*ApiKey::API_SCOPES, :mfa)
  end
end

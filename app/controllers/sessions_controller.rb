class SessionsController < Clearance::SessionsController
  before_action :redirect_to_signin, unless: :signed_in?, only: %i[verify authenticate]
  before_action :ensure_not_blocked, only: :create

  def create
    @user = find_user

    if @user && (@user.mfa_enabled? || @user.webauthn_credentials.any?)
      if @user.webauthn_credentials.any?
        @webauthn_options = @user.webauthn_options_for_get

        session[:webauthn_authentication] = {
          "challenge" => @webauthn_options.challenge,
          "user" => @user.display_id
        }
      end

      if @user.mfa_enabled?
        session[:mfa_user] = @user.display_id
      end

      render "sessions/prompt"
    else
      do_login
    end
  end

  def webauthn_create
    @user = User.find_by_slug!(session.dig(:webauthn_authentication, "user"))
    @challenge = session.dig(:webauthn_authentication, "challenge")

    if params[:credentials].blank?
      login_failure("Credentials required")
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

    do_login
  rescue WebAuthn::Error => e
    login_failure(e.message)
  ensure
    session.delete(:webauthn_authentication)
  end

  def mfa_create
    @user = User.find_by_slug(session[:mfa_user])
    session.delete(:mfa_user)

    if (@user&.mfa_enabled? || @user&.mfa_recovery_codes&.any?) && @user&.otp_verified?(params[:otp])
      do_login
    else
      login_failure(t("multifactor_auths.incorrect_otp"))
    end
  end

  def verify
  end

  def authenticate
    if verify_user
      session[:verification] = Time.current + Gemcutter::PASSWORD_VERIFICATION_EXPIRY
      redirect_to session.delete(:redirect_uri) || root_path
    else
      flash[:alert] = t("profiles.request_denied")
      render :verify, status: :unauthorized
    end
  end

  private

  def verify_user
    current_user.authenticated? verify_password_params[:password]
  end

  def verify_password_params
    params.require(:verify_password).permit(:password)
  end

  def do_login
    sign_in(@user) do |status|
      if status.success?
        StatsD.increment "login.success"
        redirect_back_or(url_after_create)
      else
        login_failure(status.failure_message)
      end
    end
  end

  def login_failure(message)
    StatsD.increment "login.failure"
    respond_to do |format|
      format.json do
        render json: { message: message }, status: :unauthorized
      end
      format.html do
        flash.now.notice = message
        render template: "sessions/new", status: :unauthorized
      end
    end
  end

  def session_params
    params.require(:session)
  end

  def find_user
    password = session_params[:password].is_a?(String) && session_params.fetch(:password)

    User.authenticate(who, password) if who && password
  end

  def who
    session_params[:who].is_a?(String) && session_params.fetch(:who)
  end

  def url_after_create
    dashboard_path
  end

  def ensure_not_blocked
    user = User.find_by_blocked(who)
    return unless user&.blocked_email

    flash.now.alert = t(".account_blocked")
    render template: "sessions/new", status: :unauthorized
  end
end

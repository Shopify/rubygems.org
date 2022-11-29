module WebauthnConcern
  extend ActiveSupport::Concern

  included do
    has_many :webauthn_credentials, dependent: :destroy

    after_initialize do
      self.webauthn_id ||= WebAuthn.generate_user_id
    end
  end

  def webauthn_options_for_create
    WebAuthn::Credential.options_for_create(
      user: {
        id: webauthn_id,
        name: display_id
      },
      exclude: webauthn_credentials.pluck(:external_id)
    )
  end

  def webauthn_options_for_get
    WebAuthn::Credential.options_for_get(
      allow: webauthn_credentials.pluck(:external_id)
    )
  end

  # name wip
  def refresh_webauthn_token
    self.webauthn_token = Clearance::Token.new
    self.webauthn_token_expires_at = 5.minutes.from_now
    self.webauthn_otp = nil
    self.webauthn_otp_expires_at = nil
    save!(validate: false)
    webauthn_token
  end
end

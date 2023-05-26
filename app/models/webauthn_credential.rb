class WebauthnCredential < ApplicationRecord
  belongs_to :user

  validates :external_id, uniqueness: true, presence: true
  validates :public_key, presence: true
  validates :nickname, presence: true, uniqueness: { scope: :user_id }
  validates :sign_count, presence: true, numericality: { greater_than_or_equal_to: 0 }

  after_create :send_creation_email
  after_destroy :send_deletion_email
  after_create :set_user_mfa_level_create
  after_destroy :set_user_mfa_level_destroy

  private

  def send_creation_email
    Mailer.webauthn_credential_created(id).deliver_later
  end

  def send_deletion_email
    Mailer.webauthn_credential_removed(user_id, nickname, Time.now.utc).deliver_later
  end

  def set_user_mfa_level_create
    if user.count_webauthn_credentials && user.totp_disabled?
      user.update!(mfa_level: "ui_and_api")
    end
  end

  def set_user_mfa_level_destroy
    if user.webauthn_credentials.empty? && user.totp_disabled?
      user.update!(mfa_level: "disabled")
    end
  end
end

class WebauthnCredential < ApplicationRecord
  belongs_to :user

  validates :external_id, uniqueness: true, presence: true
  validates :public_key, presence: true
  validates :nickname, presence: true
  validates :sign_count, presence: true, numericality: true

  validate do
    errors.add(:user, I18n.t("webauthn_credentials.errors.mfa_disabled")) if user.mfa_disabled?
  end
end

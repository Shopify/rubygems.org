class WebauthnCredential < ApplicationRecord
  belongs_to :user

  validates :external_id, uniqueness: true, presence: true
  validates :public_key, presence: true
  validates :nickname, presence: true
  validates :sign_count, presence: true, numericality: true

  validate do
    if user.mfa_disabled?
      errors.add(:user, I18n.t("webauthn_credentials.errors.mfa_disabled"))
    end
  end
end

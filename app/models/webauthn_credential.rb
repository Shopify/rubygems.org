class WebauthnCredential < ApplicationRecord
  belongs_to :user

  validates :external_id, uniqueness: true, presence: true
  validates :public_key, presence: true
  validates :nickname, presence: true
  validates :sign_count, presence: true
  validates :sign_count, numericality: { greater_than_or_equal_to: 0 }
end

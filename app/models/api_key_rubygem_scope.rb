class ApiKeyRubygemScope < ApplicationRecord
  belongs_to :api_key
  belongs_to :ownership
  # when changing scopes, before destroy gets called which is unintended
  # ended up adding a method in ownership to call mark_api_key_invalid
  # before_destroy :mark_api_key_invalid

  validates :ownership_id, uniqueness: { scope: :api_key_id }
  validates :api_key, :ownership, presence: true

  def mark_api_key_invalid
    api_key.update!(invalid_at: Time.now.utc)
  end
end
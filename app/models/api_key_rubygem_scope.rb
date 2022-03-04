class ApiKeyRubygemScope < ApplicationRecord
  belongs_to :api_key
  belongs_to :ownership

  validates :ownership_id, uniqueness: { scope: :api_key_id }
  validates :api_key, :ownership, presence: true
end
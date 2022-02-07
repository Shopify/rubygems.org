class ApiKeysRubygems < ApplicationRecord
  belongs_to :api_key
  belongs_to :rubygem

  validates :rubygem_id, uniqueness: { scope: :api_key_id }
  validates :api_key, :rubygem, presence: true
end

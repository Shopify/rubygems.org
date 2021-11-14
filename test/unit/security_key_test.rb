require "test_helper"

class SecurityKeyTest < ActiveSupport::TestCase
  subject { build(:security_key) }

  should belong_to :user
  should validate_presence_of(:external_id)
  should validate_uniqueness_of(:external_id)
  should validate_presence_of(:public_key)
  should validate_presence_of(:nickname)
  should validate_presence_of(:sign_count)
  should validate_numericality_of(:sign_count)
end

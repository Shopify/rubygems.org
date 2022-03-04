require "test_helper"

class ApiKeyRubygemScopeTest < ActiveSupport::TestCase
  should belong_to :api_key
  should belong_to :ownership
  should validate_uniqueness_of(:ownership_id).scoped_to(:api_key_id)
  should validate_presence_of(:ownership)
  should validate_presence_of(:api_key)
end

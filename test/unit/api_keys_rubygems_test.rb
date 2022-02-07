require "test_helper"

class ApiKeysRubygemsTest < ActiveSupport::TestCase
  should belong_to :api_key
  should belong_to :rubygem
  should validate_uniqueness_of(:rubygem_id).scoped_to(:api_key_id)
  should validate_presence_of(:rubygem)
  should validate_presence_of(:api_key)
end

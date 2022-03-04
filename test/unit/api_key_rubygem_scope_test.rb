require "test_helper"

class ApiKeyRubygemScopeTest < ActiveSupport::TestCase
  should belong_to :api_key
  should belong_to :ownership
  should validate_presence_of(:ownership)
  should validate_presence_of(:api_key)
  should validate_uniqueness_of(:ownership_id).scoped_to(:api_key_id)

  setup do
    @api_key = create(:api_key)
    @rubygem = create(:rubygem)
    @ownership = create(:ownership, rubygem: @rubygem)
    @api_key_scope = create(:api_key_rubygem_scope, api_key: @api_key, ownership: @ownership)
  end

  should "be valid with factory" do
    assert build(:api_key_rubygem_scope).valid?
  end

  should "#mark_api_key_invalid updates invalid_at on api key" do
    assert_nil @api_key.invalid_at

    freeze_time do
      @api_key_scope.send(:mark_api_key_invalid)
      assert_equal Time.current, @api_key.invalid_at
    end
  end
end

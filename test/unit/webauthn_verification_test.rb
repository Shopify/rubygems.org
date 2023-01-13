require "test_helper"

class WebauthnVerificationTest < ActiveSupport::TestCase
  subject { build(:webauthn_verification) }

  should belong_to :user

  should validate_uniqueness_of(:user_id)
  should validate_presence_of(:path_token)
  should validate_uniqueness_of(:path_token)
  should validate_presence_of(:path_token_expires_at)

  context "#expire_path_token" do
    setup do
      travel_to Time.utc(2023, 1, 1, 0, 0, 0) do
        user = create(:user)
        @verification = create(:webauthn_verification, user: user)
      end
    end

    should "set the path_token_expires_at to 1 second ago" do
      travel_to Time.utc(2023, 1, 1, 0, 1, 0) do
        @verification.expire_path_token
        assert_equal Time.utc(2023, 1, 1, 0, 0, 59), @verification.path_token_expires_at
      end
    end
  end

  context "#path_token_expired?" do
    setup do
      travel_to Time.utc(2023, 1, 1, 0, 0, 0) do
        user = create(:user)
        @verification = create(:webauthn_verification, user: user)
      end
    end

    context "when the token is still live" do
      should "return false" do
        travel_to Time.utc(2023, 1, 1, 0, 0, 1) do
          refute_predicate @verification, :path_token_expired?
        end
      end
    end

    context "when the token has expired" do
      should "return true" do
        travel_to Time.utc(2023, 9, 9, 9, 9, 9) do
          assert_predicate @verification, :path_token_expired?
        end
      end
    end
  end

  context "#generate_otp" do
    setup do
      @webauthn_verification = create(:webauthn_verification, otp: nil, otp_expires_at: nil)
      @generated_time = Time.utc(2023, 1, 1, 0, 0, 0)
      travel_to @generated_time do
        @webauthn_verification.generate_otp
      end
      @webauthn_verification.reload
    end

    should "create a token that is 20 characters long" do
      assert_equal 20, @webauthn_verification.otp.length
    end

    should "set a 2 minute expiry" do
      assert_equal @generated_time + 2.minutes, @webauthn_verification.otp_expires_at
    end
  end
end

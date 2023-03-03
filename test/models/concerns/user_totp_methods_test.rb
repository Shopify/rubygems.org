require "test_helper"

class UserMultifactorMethodsTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
  end

  context "#disable_totp!" do
    setup do
      @user.enable_mfa!(ROTP::Base32.random_base32, :ui_only)
      @user.disable_totp!
    end

    should "disable mfa" do
      assert_predicate @user, :mfa_disabled?
      assert_empty @user.mfa_seed
      assert_empty @user.mfa_recovery_codes
    end
  end

  context "#verify_and_enable_mfa!" do
    setup do
      @seed = ROTP::Base32.random_base32
      @expiry = 30.minutes.from_now
    end

    should "enable mfa" do
      @user.verify_and_enable_mfa!(
        @seed,
        :ui_and_api,
        ROTP::TOTP.new(@seed).now,
        @expiry
      )

      assert_predicate @user, :mfa_enabled?
    end

    should "add error if qr code expired" do
      @user.verify_and_enable_mfa!(
        @seed,
        :ui_and_api,
        ROTP::TOTP.new(@seed).now,
        5.minutes.ago
      )

      refute_predicate @user, :mfa_enabled?
      expected_error = "The QR-code and key is expired. Please try registering a new device again."
      assert_contains @user.errors[:base], expected_error
    end

    should "add error if otp code is incorrect" do
      @user.verify_and_enable_mfa!(
        @seed,
        :ui_and_api,
        ROTP::TOTP.new(ROTP::Base32.random_base32).now,
        @expiry
      )

      refute_predicate @user, :mfa_enabled?
      assert_contains @user.errors[:base], "Your OTP code is incorrect."
    end
  end

  context "#enable_mfa!" do
    setup do
      @seed = ROTP::Base32.random_base32
      @level = :ui_and_api
      @user.enable_mfa!(@seed, @level)
    end

    should "enable mfa" do
      assert_equal @seed, @user.mfa_seed
      assert_predicate @user, :mfa_ui_and_api?
      assert_equal 10, @user.mfa_recovery_codes.length
    end
  end
end

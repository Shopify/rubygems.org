require "test_helper"

class MultifactorAuthableTest < ActiveSupport::TestCase
  setup do
    @multifactor_authable_class = User
    @multifactor_authable = create(@multifactor_authable_class.name.underscore.to_sym)
  end

  context "#mfa_enabled" do
    should "return true if multifactor auth is not disabled" do
      @multifactor_authable.enable_mfa!(ROTP::Base32.random_base32, :ui_only)
      assert_predicate @multifactor_authable, :mfa_enabled?
    end

    should "return true if multifactor auth is disabled" do
      @multifactor_authable.disable_mfa!
      refute_predicate @multifactor_authable, :mfa_enabled?
    end
  end

  context "#disable_mfa!" do
    setup do
      @multifactor_authable.enable_mfa!(ROTP::Base32.random_base32, :ui_only)
      @multifactor_authable.disable_mfa!
    end

    should "disable mfa" do
      assert_predicate @multifactor_authable, :mfa_disabled?
      assert_empty @multifactor_authable.mfa_seed
      assert_empty @multifactor_authable.mfa_recovery_codes
    end
  end

  context "#verify_and_enable_mfa!" do
    setup do
      @seed = ROTP::Base32.random_base32
      @expiry = 30.minutes.from_now
    end

    should "enable mfa" do
      @multifactor_authable.verify_and_enable_mfa!(
        @seed,
        :ui_and_api,
        ROTP::TOTP.new(@seed).now,
        @expiry
      )

      assert_predicate @multifactor_authable, :mfa_enabled?
    end

    should "add error if qr code expired" do
      @multifactor_authable.verify_and_enable_mfa!(
        @seed,
        :ui_and_api,
        ROTP::TOTP.new(@seed).now,
        5.minutes.ago
      )

      refute_predicate @multifactor_authable, :mfa_enabled?
      expected_error = "The QR-code and key is expired. Please try registering a new device again."
      assert_contains @multifactor_authable.errors[:base], expected_error
    end

    should "add error if otp code is incorrect" do
      @multifactor_authable.verify_and_enable_mfa!(
        @seed,
        :ui_and_api,
        ROTP::TOTP.new(ROTP::Base32.random_base32).now,
        @expiry
      )

      refute_predicate @multifactor_authable, :mfa_enabled?
      assert_contains @multifactor_authable.errors[:base], "Your OTP code is incorrect."
    end
  end

  context "#enable_mfa!" do
    setup do
      @seed = ROTP::Base32.random_base32
      @level = :ui_and_api
      @multifactor_authable.enable_mfa!(@seed, @level)
    end

    should "enable mfa" do
      assert_equal @seed, @multifactor_authable.mfa_seed
      assert_predicate @multifactor_authable, :mfa_ui_and_api?
      assert_equal 10, @multifactor_authable.mfa_recovery_codes.length
    end
  end

  context "#mfa_gem_signin_authorized?" do
    setup do
      @seed = ROTP::Base32.random_base32
    end

    should "return true if mfa is ui_and_api and otp is correct" do
      @multifactor_authable.enable_mfa!(@seed, :ui_and_api)
      assert @multifactor_authable.mfa_gem_signin_authorized?(ROTP::TOTP.new(@seed).now)
    end

    should "return true if mfa is ui_and_gem_signin and otp is correct" do
      @multifactor_authable.enable_mfa!(@seed, :ui_and_gem_signin)
      assert @multifactor_authable.mfa_gem_signin_authorized?(ROTP::TOTP.new(@seed).now)
    end

    should "return true if mfa is disabled" do
      assert @multifactor_authable.mfa_gem_signin_authorized?(ROTP::TOTP.new(@seed).now)
    end

    should "return true if mfa is ui_only" do
      @multifactor_authable.enable_mfa!(@seed, :ui_only)
      assert @multifactor_authable.mfa_gem_signin_authorized?(ROTP::TOTP.new(@seed).now)
    end

    should "return false if otp is incorrect" do
      @multifactor_authable.enable_mfa!(@seed, :ui_and_gem_signin)
      refute @multifactor_authable.mfa_gem_signin_authorized?(ROTP::TOTP.new(ROTP::Base32.random_base32).now)
    end
  end

  context "#mfa_recommended_not_yet_enabled?" do
    setup do
      @popular_rubygem = create(:rubygem)
      GemDownload.increment(
        Rubygem::MFA_RECOMMENDED_THRESHOLD + 1,
        rubygem_id: @popular_rubygem.id
      )
    end

    should "return true if instance owns a gem that exceeds recommended threshold and has mfa disabled" do
      create(:ownership, user: @multifactor_authable, rubygem: @popular_rubygem)

      assert_predicate @multifactor_authable, :mfa_recommended_not_yet_enabled?
    end

    should "return false if instance owns a gem that exceeds recommended threshold and has mfa enabled" do
      create(:ownership, user: @multifactor_authable, rubygem: @popular_rubygem)
      @multifactor_authable.enable_mfa!(ROTP::Base32.random_base32, :ui_only)

      refute_predicate @multifactor_authable, :mfa_recommended_not_yet_enabled?
    end

    should "return false if instance does not own a gem that exceeds recommended threshold and has mfa disabled" do
      create(:ownership, user: @multifactor_authable, rubygem: create(:rubygem))

      refute_predicate @multifactor_authable, :mfa_recommended_not_yet_enabled?
    end
  end

  context "#mfa_recommended_weak_level_enabled?" do
    setup do
      @popular_rubygem = create(:rubygem)
      GemDownload.increment(
        Rubygem::MFA_RECOMMENDED_THRESHOLD + 1,
        rubygem_id: @popular_rubygem.id
      )
      @multifactor_authable.enable_mfa!(ROTP::Base32.random_base32, :ui_only)
    end

    should "return true if instance owns a gem that exceeds recommended threshold and has mfa ui_only" do
      create(:ownership, user: @multifactor_authable, rubygem: @popular_rubygem)

      assert_predicate @multifactor_authable, :mfa_recommended_weak_level_enabled?
    end

    should "return false if instance owns a gem that exceeds recommended threshold and has mfa disabled" do
      create(:ownership, user: @multifactor_authable, rubygem: @popular_rubygem)
      @multifactor_authable.disable_mfa!

      refute_predicate @multifactor_authable, :mfa_recommended_weak_level_enabled?
    end

    should "return false if instance does not own a gem that exceeds recommended threshold and has mfa disabled" do
      create(:ownership, user: @multifactor_authable, rubygem: create(:rubygem))

      refute_predicate @multifactor_authable, :mfa_recommended_weak_level_enabled?
    end
  end

  context "#otp_verified?" do
    setup do
      @multifactor_authable.enable_mfa!(ROTP::Base32.random_base32, :ui_and_api)
    end

    should "return true if otp is correct" do
      assert @multifactor_authable.otp_verified?(ROTP::TOTP.new(@multifactor_authable.mfa_seed).now)
    end

    should "return true for otp in last interval" do
      last_otp = ROTP::TOTP.new(@multifactor_authable.mfa_seed).at(Time.current - 30)
      assert @multifactor_authable.otp_verified?(last_otp)
    end

    should "return true for otp in next interval" do
      next_otp = ROTP::TOTP.new(@multifactor_authable.mfa_seed).at(Time.current + 30)
      assert @multifactor_authable.otp_verified?(next_otp)
    end

    should "return false if otp is incorrect" do
      refute @multifactor_authable.otp_verified?(ROTP::TOTP.new(ROTP::Base32.random_base32).now)
    end

    should "return true if recovery code is correct" do
      recovery_code = @multifactor_authable.mfa_recovery_codes.first

      assert @multifactor_authable.otp_verified?(recovery_code)
      refute_includes @multifactor_authable.mfa_recovery_codes, recovery_code
    end
  end

  context ".without_mfa" do
    setup do
      create(@multifactor_authable_class.name.underscore.to_sym, mfa_level: :ui_and_api)
    end

    should "return instances without mfa" do
      multifactor_authable_without_mfa = @multifactor_authable_class.without_mfa

      assert_equal 1, multifactor_authable_without_mfa.size
      assert_equal @multifactor_authable, multifactor_authable_without_mfa.first
    end
  end
end

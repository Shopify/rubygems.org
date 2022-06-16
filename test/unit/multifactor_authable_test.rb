require "test_helper"

class MultifactorAuthableTest < ActiveSupport::TestCase
  context "two factor authentication" do
    setup do
      @user = create(:user)
    end

    should "disable mfa by default" do
      refute_predicate @user, :mfa_enabled?
    end

    context "when enabled" do
      setup do
        @user.enable_mfa!(ROTP::Base32.random_base32, :ui_only)
      end

      should "be able to use a recovery code only once" do
        code = @user.mfa_recovery_codes.first
        assert @user.otp_verified?(code)
        refute @user.otp_verified?(code)
      end

      should "be able to verify correct OTP" do
        assert @user.otp_verified?(ROTP::TOTP.new(@user.mfa_seed).now)
      end

      should "return true for mfa status check" do
        assert_predicate @user, :mfa_enabled?
        refute_predicate @user, :mfa_disabled?
      end

      should "return true for otp in last interval" do
        last_otp = ROTP::TOTP.new(@user.mfa_seed).at(Time.current - 30)
        assert @user.otp_verified?(last_otp)
      end

      should "return true for otp in next interval" do
        next_otp = ROTP::TOTP.new(@user.mfa_seed).at(Time.current + 30)
        assert @user.otp_verified?(next_otp)
      end

      context "blocking user with api key" do
        setup { create(:api_key, user: @user) }

        should "reset email and mfa" do
          assert_changed(@user, :email, :password, :api_key, :mfa_seed, :remember_token) do
            @user.block!
          end

          assert @user.email.start_with?("security+locked-")
          assert @user.email.end_with?("@rubygems.org")
          assert_empty @user.mfa_recovery_codes
          assert_predicate @user, :mfa_disabled?
        end

        should "reset api key" do
          @user.block!
          assert_nil @user.api_key
          assert_empty @user.api_keys
        end
      end
    end

    context "when disabled" do
      setup do
        @user.disable_mfa!
      end

      should "return false for verifying OTP" do
        refute @user.otp_verified?("")
      end

      should "return false for mfa status check" do
        refute_predicate @user, :mfa_enabled?
        assert_predicate @user, :mfa_disabled?
      end
    end
  end

  context "strong_mfa_level?" do
    should "be true if the users mfa level is ui_and_api" do
      user = create(:user, mfa_level: "ui_and_api")

      assert_predicate user, :strong_mfa_level?
    end

    should "be true if the users mfa level is ui_and_gem_signin" do
      user = create(:user, mfa_level: "ui_and_gem_signin")

      assert_predicate user, :strong_mfa_level?
    end

    should "be false if users mfa level is ui_only" do
      user = create(:user, mfa_level: "ui_only")

      refute_predicate user, :strong_mfa_level?
    end

    should "be false if users has mfa disabled" do
      user = create(:user, mfa_level: "disabled")

      refute_predicate user, :strong_mfa_level?
    end
  end

  context "recommend mfa" do
    setup do
      @user = create(:user)
      @rubygem = create(:rubygem)
      create(:ownership, user: @user, rubygem: @rubygem)
      assert_equal [@rubygem], @user.rubygems
    end

    context "when a user doesn't own a gem with more downloads than the recommended threshold" do
      setup do
        GemDownload.increment(
          Rubygem::MFA_RECOMMENDED_THRESHOLD,
          rubygem_id: @rubygem.id
        )
      end

      should "return false for mfa_recommended?" do
        refute_predicate @user, :mfa_recommended?
      end

      should "return false for mfa_recommended_not_yet_enabled?" do
        refute_predicate @user, :mfa_recommended_not_yet_enabled?
      end

      should "return false for mfa_recommended_weak_level_enabled?" do
        refute_predicate @user, :mfa_recommended_weak_level_enabled?
      end
    end

    context "when mfa disabled user owns a gem with more downloads than the recommended threshold" do
      setup do
        GemDownload.increment(
          Rubygem::MFA_RECOMMENDED_THRESHOLD + 1,
          rubygem_id: @rubygem.id
        )
      end

      should "return true for mfa_recommended?" do
        assert_predicate @user, :mfa_recommended?
      end

      should "return true for mfa_recommended_not_yet_enabled?" do
        assert_predicate @user, :mfa_recommended_not_yet_enabled?
      end

      should "return false for mfa_recommended_weak_level_enabled?" do
        refute_predicate @user, :mfa_recommended_weak_level_enabled?
      end
    end

    context "when mfa `ui_only` user owns a gem with more downloads than the recommended threshold" do
      setup do
        @user.enable_mfa!(ROTP::Base32.random_base32, :ui_only)

        GemDownload.increment(
          Rubygem::MFA_RECOMMENDED_THRESHOLD + 1,
          rubygem_id: @rubygem.id
        )
      end

      should "return true for mfa_recommended?" do
        assert_predicate @user, :mfa_recommended?
      end

      should "return false for mfa_recommended_not_yet_enabled?" do
        refute_predicate @user, :mfa_recommended_not_yet_enabled?
      end

      should "return true for mfa_recommended_weak_level_enabled?" do
        assert_predicate @user, :mfa_recommended_weak_level_enabled?
      end
    end
    


    context "when strong user owns a gem with more downloads than the recommended threshold" do
      setup do
        @user.enable_mfa!(ROTP::Base32.random_base32, :ui_and_api)

        GemDownload.increment(
          Rubygem::MFA_RECOMMENDED_THRESHOLD + 1,
          rubygem_id: @rubygem.id
        )
      end

      should "return false for mfa_recommended?" do
        refute_predicate @user, :mfa_recommended?
      end

      should "return false for mfa_recommended_not_yet_enabled?" do
        refute_predicate @user, :mfa_recommended_not_yet_enabled?
      end

      should "return false for mfa_recommended_weak_level_enabled?" do
        refute_predicate @user, :mfa_recommended_weak_level_enabled?
      end
    end
  end

  context ".without_mfa" do
    setup do
      create(:user, handle: "has_mfa", mfa_level: "ui_and_api")
      create(:user, handle: "no_mfa", mfa_level: "disabled")
    end

    should "return only users without mfa" do
      users_without_mfa = User.without_mfa

      assert_equal 1, users_without_mfa.size
      assert_equal "no_mfa", users_without_mfa.first.handle
    end
  end
end

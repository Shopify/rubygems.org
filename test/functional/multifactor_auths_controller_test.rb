require "test_helper"

class MultifactorAuthsControllerTest < ActionController::TestCase
  include ActionMailer::TestHelper

  context "when logged in" do
    setup do
      @user = create(:user)
      sign_in_as(@user)
      @request.cookies[:mfa_feature] = "true"
    end

    context "when totp is enabled" do
      setup do
        @user.enable_totp!(ROTP::Base32.random_base32, :ui_only)
      end

      context "on GET to new totp mfa" do
        setup do
          get :new
        end

        should respond_with :redirect
        should redirect_to("the settings page") { edit_settings_path }

        should "say TOTP is already enabled" do
          assert_equal "Your multi-factor authentication has been enabled. " \
                       "To reconfigure multi-factor authentication, you'll have to disable it first.", flash[:error]
        end
      end

      context "on POST to create totp mfa" do
        setup do
          post :create, params: { otp: ROTP::TOTP.new(@user.mfa_seed).now }
        end

        should respond_with :redirect
        should redirect_to("the settings page") { edit_settings_path }

        should "keep mfa enabled" do
          assert_predicate @user.reload, :mfa_enabled?
          assert_emails 0
        end
      end

      context "on PUT to update mfa level" do
        context "on updating to ui_and_api" do
          setup do
            freeze_time
            put :update, params: { level: "ui_and_api" }
          end

          should "render totp prompt" do
            assert page.has_content?("OTP code")
            refute page.has_content?("Security Device")
          end

          should "not update mfa level" do
            assert_predicate @user.reload, :mfa_ui_only?
          end

          should "set mfa level in session" do
            assert_equal "ui_and_api", @controller.session[:level]
          end

          should "set expiry in session" do
            assert_equal 15.minutes.from_now.to_s, session[:mfa_expires_at]
          end

          teardown do
            travel_back
          end
        end

        context "on updating to ui_and_gem_signin" do
          setup do
            freeze_time
            put :update, params: { level: "ui_and_api" }
          end

          should "render totp prompt" do
            assert page.has_content?("OTP code")
            refute page.has_content?("Security Device")
          end

          should "not update mfa level" do
            assert_predicate @user.reload, :mfa_ui_only?
          end

          should "set mfa level in session" do
            assert_equal "ui_and_api", @controller.session[:level]
          end

          should "set expiry in session" do
            assert_equal 15.minutes.from_now.to_s, session[:mfa_expires_at]
          end

          teardown do
            travel_back
          end
        end

        context "on updating to invalid level" do
          setup do
            put :update, params: { level: "disabled" }
          end

          should "redirect to settings page" do
            assert_redirected_to edit_settings_path
            assert_equal "Invalid MFA level.", flash[:error]
          end

          should "not set session variables" do
            assert_nil @controller.session[:level]
            assert_nil @controller.session[:mfa_expires_at]
          end
        end
      end

      context "on PUT to mfa_update" do
        context "when otp is correct" do
          context "when redirect url is not set" do
            setup do
              put :update, params: { level: "ui_and_api" }
              put :mfa_update, params: { otp: ROTP::TOTP.new(@user.mfa_seed).now }
            end

            should redirect_to("the settings page") { edit_settings_path }

            should "update mfa level" do
              assert_predicate @user.reload, :mfa_ui_and_api?
            end

            should "clear session variables" do
              assert_nil @controller.session[:mfa_expires_at]
              assert_nil @controller.session[:level]
            end
          end

          context "when redirect url is set" do
            setup do
              @controller.session["mfa_redirect_uri"] = profile_api_keys_path
              put :update, params: { level: "ui_and_api" }
              put :mfa_update, params: { otp: ROTP::TOTP.new(@user.mfa_seed).now }
            end

            should redirect_to("the api keys index") { profile_api_keys_path }
          end
        end

        context "when otp is incorrect" do
          setup do
            put :update, params: { level: "ui_and_api" }
            put :mfa_update, params: { otp: "123456" }
          end

          should redirect_to("the settings page") { edit_settings_path }

          should "not update mfa level" do
            assert_predicate @user.reload, :mfa_ui_only?
          end

          should "set flash error" do
            assert_equal "Your OTP code is incorrect.", flash[:error]
          end

          should "clear session variables" do
            assert_nil @controller.session[:mfa_expires_at]
            assert_nil @controller.session[:level]
            assert_nil @controller.session[:mfa_redirect_uri]
          end
        end

        context "when session is expired" do
          setup do
            get :update, params: { level: "ui_and_api" }

            travel 16.minutes do
              post :mfa_update, params: { otp: ROTP::TOTP.new(@user.mfa_seed).now }
            end
          end

          should redirect_to("the settings page") { edit_settings_path }

          should "not update mfa level" do
            assert_predicate @user.reload, :mfa_ui_only?
          end

          should "set flash error" do
            assert_equal "Your login page session has expired.", flash[:error]
          end

          should "clear session variables" do
            assert_nil @controller.session[:mfa_expires_at]
            assert_nil @controller.session[:level]
            assert_nil @controller.session[:mfa_redirect_uri]
          end
        end
      end

      context "on PUT to webauthn_update" do
        setup do
          put :update, params: { level: "ui_and_api" }
          post :webauthn_update
        end

        should redirect_to("the settings page") { edit_settings_path }

        should "set flash error" do
          assert_equal "You don't have any security devices enabled. " \
                       "You have to associate a device to your account first.", flash[:error]
        end

        should "not update mfa level" do
          assert_predicate @user.reload, :mfa_ui_only?
        end

        should "clear session variables" do
          assert_nil @controller.session[:mfa_expires_at]
          assert_nil @controller.session[:level]
          assert_nil @controller.session[:mfa_redirect_uri]
        end
      end
    end

    context "when a webauthn device is enabled" do
      setup do
        @user.update!(mfa_level: "ui_only") # remove this when we enable mfa when a webauthn device is created
        create(:webauthn_credential, user: @user)
      end

      context "on POST to create totp mfa" do
        setup do
          @seed = ROTP::Base32.random_base32
          @controller.session[:mfa_seed] = @seed
          @controller.session[:mfa_seed_expire] = Gemcutter::MFA_KEY_EXPIRY.from_now.utc.to_i

          perform_enqueued_jobs only: ActionMailer::MailDeliveryJob do
            post :create, params: { otp: ROTP::TOTP.new(@seed).now }
          end
        end

        should respond_with :success

        should "keep mfa enabled" do
          assert_predicate @user.reload, :mfa_enabled?
        end

        should "send totp enabled email" do
          assert_emails 1
          assert_equal "Multi-factor authentication enabled on RubyGems.org", last_email.subject
          assert_equal [@user.email], last_email.to
        end
      end

      context "on PUT to update mfa level" do
        context "on updating to ui_and_api" do
          setup do
            freeze_time
            put :update, params: { level: "ui_and_api" }
          end

          should "render totp prompt" do
            refute page.has_content?("OTP code")
            assert page.has_content?("Security Device")
          end

          should "not update mfa level" do
            assert_predicate @user.reload, :mfa_ui_only?
          end

          should "set mfa level in session" do
            assert_equal "ui_and_api", @controller.session[:level]
          end

          should "set expiry in session" do
            assert_equal 15.minutes.from_now.to_s, session[:mfa_expires_at]
          end

          teardown do
            travel_back
          end
        end

        context "on updating to ui_and_gem_signin" do
          setup do
            freeze_time
            put :update, params: { level: "ui_and_api" }
          end

          should "render totp prompt" do
            refute page.has_content?("OTP code")
            assert page.has_content?("Security Device")
          end

          should "not update mfa level" do
            assert_predicate @user.reload, :mfa_ui_only?
          end

          should "set mfa level in session" do
            assert_equal "ui_and_api", @controller.session[:level]
          end

          should "set expiry in session" do
            assert_equal 15.minutes.from_now.to_s, session[:mfa_expires_at]
          end

          teardown do
            travel_back
          end
        end

        context "on updating to invalid level" do
          setup do
            put :update, params: { level: "disabled" }
          end

          should "redirect to settings page" do
            assert_redirected_to edit_settings_path
            assert_equal "Invalid MFA level.", flash[:error]
          end

          should "not set session variables" do
            assert_nil @controller.session[:level]
            assert_nil @controller.session[:mfa_expires_at]
          end
        end
      end

      context "on PUT to mfa_update" do
        setup do
          put :update, params: { level: "ui_and_api" }
          post :mfa_update
        end

        should redirect_to("the settings page") { edit_settings_path }

        should "set flash error" do
          assert_equal "You don't have an authenticator app enabled. You have to enable it first.", flash[:error]
        end

        should "not update mfa level" do
          assert_predicate @user.reload, :mfa_ui_only?
        end

        should "clear session variables" do
          assert_nil @controller.session[:mfa_expires_at]
          assert_nil @controller.session[:level]
          assert_nil @controller.session[:mfa_redirect_uri]
        end
      end
    end

    context "when there are no mfa devices" do
      context "on POST to create totp mfa" do
        setup do
          @seed = ROTP::Base32.random_base32
          @controller.session[:mfa_seed] = @seed
        end

        context "when qr-code is not expired" do
          setup do
            perform_enqueued_jobs only: ActionMailer::MailDeliveryJob do
              @controller.session[:mfa_seed_expire] = Gemcutter::MFA_KEY_EXPIRY.from_now.utc.to_i
              post :create, params: { otp: ROTP::TOTP.new(@seed).now }
            end
          end

          should respond_with :success
          should "show recovery codes" do
            @user.reload.mfa_recovery_codes.each do |code|
              assert page.has_content?(code)
            end
          end

          should "enable mfa" do
            assert_predicate @user.reload, :mfa_enabled?
          end

          should "send mfa enabled email" do
            assert_emails 1
            assert_equal "Multi-factor authentication enabled on RubyGems.org", last_email.subject
            assert_equal [@user.email], last_email.to
          end
        end

        context "when qr-code is expired" do
          setup do
            @controller.session[:mfa_seed_expire] = 1.minute.ago
            post :create, params: { otp: ROTP::TOTP.new(@seed).now }
          end

          should respond_with :redirect
          should redirect_to("the settings page") { edit_settings_path }

          should "set error flash message" do
            refute_empty flash[:error]
          end
          should "keep mfa disabled" do
            refute_predicate @user.reload, :mfa_enabled?
          end
          should "not send mfa enabled email" do
            assert_emails 0
          end
        end
      end

      context "on PUT to update mfa level" do
        setup do
          put :update
        end

        should respond_with :redirect
        should redirect_to("the settings page") { edit_settings_path }

        should "keep mfa disabled" do
          refute_predicate @user.reload, :mfa_enabled?
        end

        should "say MFA is not enabled" do
          assert_equal "Your multi-factor authentication has not been enabled. " \
                       "You have to enable it first.", flash[:error]
        end
      end
    end

    context "when user owns a gem with more than MFA_REQUIRED_THRESHOLD downloads" do
      setup do
        @rubygem = create(:rubygem)
        create(:ownership, rubygem: @rubygem, user: @user)
        GemDownload.increment(
          Rubygem::MFA_REQUIRED_THRESHOLD + 1,
          rubygem_id: @rubygem.id
        )
        @redirect_paths = [adoptions_profile_path,
                           dashboard_path,
                           delete_profile_path,
                           edit_profile_path,
                           new_profile_api_key_path,
                           notifier_path,
                           profile_api_keys_path,
                           verify_session_path]
      end

      # context "user has mfa set to weak level" do
      #   setup do
      #     @seed = ROTP::Base32.random_base32
      #     @user.enable_totp!(@seed, :ui_only)
      #   end

      #   should "redirect user back to mfa_redirect_uri after successful mfa setup" do
      #     @redirect_paths.each do |path|
      #       session[:mfa_redirect_uri] = path
      #       post :update, params: { otp: ROTP::TOTP.new(@seed).now, level: "ui_and_api" }

      #       assert_redirected_to path
      #       assert_nil session[:mfa_redirect_uri]
      #     end
      #   end

      #   should "not redirect user back to mfa_redirect_uri after failed mfa setup, but mfa_redirect_uri unchanged" do
      #     @redirect_paths.each do |path|
      #       session[:mfa_redirect_uri] = path
      #       post :update, params: { otp: "12345", level: "ui_and_api" }

      #       assert_redirected_to edit_settings_path
      #       assert_equal path, session[:mfa_redirect_uri]
      #     end
      #   end

      #   should "redirect user back to mfa_redirect_uri after a failed setup + successful setup" do
      #     @redirect_paths.each do |path|
      #       session[:mfa_redirect_uri] = path
      #       post :update, params: { otp: "12345", level: "ui_and_api" }

      #       assert_redirected_to edit_settings_path
      #       post :update, params: { otp: ROTP::TOTP.new(@seed).now, level: "ui_and_api" }

      #       assert_redirected_to path
      #       assert_nil session[:mfa_redirect_uri]
      #     end
      #   end
      # end
    end
  end
end

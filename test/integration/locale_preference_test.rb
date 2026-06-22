# frozen_string_literal: true

require "test_helper"

class LocalePreferenceTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, remember_token_expires_at: Gemcutter::REMEMBER_FOR.from_now)
    FeatureFlag.enable_globally(FeatureFlag::PATH_BASED_LOCALES)
  end

  teardown { FeatureFlag.disable_globally(FeatureFlag::PATH_BASED_LOCALES) }

  def sign_in
    post session_path(session: { who: @user.handle, password: PasswordHelpers::SECURE_TEST_PASSWORD })
  end

  test "viewing a localized page remembers the locale for a signed-in user" do
    sign_in
    get "/de"

    assert_response :success
    assert_equal "de", @user.reload.locale
  end

  test "viewing an unprefixed page clears the preference (lets a user pick English back)" do
    @user.update!(locale: "de")
    sign_in
    get "/"

    assert_response :success
    assert_nil @user.reload.locale
  end

  test "the preference is not recorded for anonymous users" do
    get "/de"

    assert_response :success
    assert_nil @user.reload.locale
  end

  test "the locale preference is not written on non-GET requests" do
    @user.update!(locale: "de")
    sign_in # POST /session, path has no locale

    assert_equal "de", @user.reload.locale, "a sign-in POST must not clobber the saved preference"
  end

  test "sign-in redirects a user with a saved locale to their localized destination" do
    @user.update!(locale: "de")
    sign_in

    assert_response :redirect
    assert_match %r{\A(http://localhost)?/de/}, response.headers["Location"]
  end

  test "sign-in does not prefix when the saved locale is the default" do
    @user.update!(locale: "en")
    sign_in

    assert_response :redirect
    refute_match %r{/en/}, response.headers["Location"]
  end
end

require "test_helper"

class WebauthnCredentialsTest < SystemTest
  setup do
    @user = create(:user)
  end

  def sign_in
    visit sign_in_path
    fill_in "Email or Username", with: @user.reload.email
    fill_in "Password", with: @user.password
    click_button "Sign in"
  end

  should "have additional credentials form" do
    sign_in
    visit edit_settings_path
    assert_text "Additional credentials"
    assert_text "You don't have any additional credentials"
    assert page.has_field?("Nickname")
    assert page.has_button?("Add additional credential")
  end

  should "show the additional credentials" do
    sign_in
    @primary = create(:webauthn_credential, :primary, user: @user)
    @backup = create(:webauthn_credential, :backup, user: @user)
    visit edit_settings_path
    assert_text "Additional credentials"
    assert_no_text "You don't have any additional credentials"
    assert_text @primary.nickname
    assert_text @backup.nickname
    assert page.has_button?("Delete")
    assert page.has_field?("Nickname")
    assert page.has_button?("Add additional credential")
  end

  should "be able to delete additional crendentials" do
    sign_in
    @webauthn_credential = create(:webauthn_credential, user: @user)
    visit edit_settings_path
    assert_text "Additional credentials"
    assert_no_text "You don't have any additional credentials"
    assert_text @webauthn_credential.nickname
    click_on "Delete"
    assert_text "You don't have any additional credentials"
    assert_no_text @webauthn_credential.nickname
  end
end

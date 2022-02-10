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

  test "has additional credentials form" do
    sign_in
    visit edit_settings_path
    assert_text "Additional credentials"
    assert_text "You don't have any additional credentials"
    assert page.has_field?("Nickname")
    assert page.has_button?("Add additional credential")
  end
end

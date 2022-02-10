require "test_helper"

class WebauthnCredentialsControllerTest < ActionController::TestCase
  context "#create" do
    context "when logged out" do
      setup do
        post :create
      end

      should redirect_to :sign_in
    end

    context "when logged in" do
      setup do
        @user = create(:user)
        sign_in_as @user
        post :create
        @json = JSON.parse(response.body)
      end

      should "return the user id" do
        assert_not_nil @json["user"]["id"]
      end

      should "return the challenge" do
        assert_not_nil @json["challenge"]
      end

      should "return no excluded credentials" do
        assert_empty @json["excludeCredentials"]
      end

      should "set the challenge in the session" do
        assert_not_nil session[:webauthn_registration]["challenge"]
      end
    end

    context "when having existing credentials" do
      setup do
        @user = create(:user)
        create_list(:webauthn_credential, 3, user: @user)
        sign_in_as @user
        post :create
        @json = JSON.parse(response.body)
      end

      should "return the user id" do
        assert_not_nil @json["user"]["id"]
      end

      should "return the challenge" do
        assert_not_nil @json["challenge"]
      end

      should "return excluded credentials" do
        assert_equal 3, @json["excludeCredentials"].size

        @json["excludeCredentials"].each do |credential|
          assert_not_nil credential["id"]
          assert_not_nil credential["type"]
        end
      end

      should "set the challenge in the session" do
        assert_not_nil session[:webauthn_registration]["challenge"]
      end
    end
  end

  context "#callback" do
    context "when logged out" do
      setup do
        post :create
      end

      should redirect_to :sign_in
    end

    context "when correctly verifying a challenge" do
      setup do
        @user = create(:user)
        sign_in_as @user
        post :create
        @challenge = JSON.parse(response.body)["challenge"]
        @origin = "http://localhost:3000"
        @client = WebAuthn::FakeClient.new(@origin, encoding: false)
        @nickname = "Touch ID on my Macbook"
        post(
          :callback,
          params: {
            credentials: WebauthnHelpers.create_result(
              client: @client,
              challenge: @challenge
            ),
            webauthn_credential: { nickname: @nickname }
          },
          format: :json
        )
      end

      should redirect_to :edit_settings

      should "create the webauthn credential" do
        assert_equal @nickname, @user.webauthn_credentials.last.nickname
        assert_equal 1, @user.webauthn_credentials.count
      end
    end
  end
end

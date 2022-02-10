class SettingsController < ApplicationController
  before_action :redirect_to_signin, unless: :signed_in?
  before_action :set_cache_headers

  def edit
    @user = current_user
    @webauthn_credential = WebauthnCredential.new(user: @user)
  end
end

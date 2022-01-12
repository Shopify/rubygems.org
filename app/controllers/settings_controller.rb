class SettingsController < ApplicationController
  before_action :redirect_to_signin, unless: :signed_in?
  before_action :redirect_to_mfa, unless: :mfa_compliant?
  before_action :set_cache_headers

  def edit
    @user = current_user
  end
end

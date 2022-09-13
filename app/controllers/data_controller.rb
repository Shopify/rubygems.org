class DataController < ApplicationController
  before_action :redirect_to_signin, unless: :signed_in?
  before_action :verify_admin_access

  def mfa_dashboard
    # Users with >= 180M downloads
    @users_mfa_required = User.joins(rubygems: :gem_download).where("gem_downloads.count > 180000000").group(:mfa_level).distinct(:id).count
    # Users with >= 165M && < 180M downloads
    @users_mfa_recommended = User.joins(rubygems: :gem_download).where("gem_downloads.count > 165000000").where("user_id not in (?)", User.joins(rubygems: :gem_download).where("gem_downloads.count > 180000000").pluck(:id)).group(:mfa_level).distinct(:id).count
    # Users with < 165M downloads
    @users_no_mfa_policy = User.joins(rubygems: :gem_download).where("gem_downloads.count < 165000000").where("user_id not in (?)", User.joins(rubygems: :gem_download).where("gem_downloads.count > 165000000").pluck(:id)).group(:mfa_level).distinct(:id).count
  end

  private
  def verify_admin_access
    return if current_user.admin?

    render_not_found
  end
end

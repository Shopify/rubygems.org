class OIDC::TrustedPublisher::GitHubActionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def avo_index? = rubygems_org_admin?
  def avo_show? = rubygems_org_admin?

  has_association :trusted_publishers
  has_association :rubygem_trusted_publishers
  has_association :pending_trusted_publishers
  has_association :rubygems
  has_association :api_keys
end

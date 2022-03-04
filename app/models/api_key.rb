class ApiKey < ApplicationRecord
  API_SCOPES = %i[index_rubygems push_rubygem yank_rubygem add_owner remove_owner access_webhooks show_dashboard].freeze

  before_validation :set_rubygem_from_name, on: %i[create update]
  belongs_to :user
  has_one :api_key_rubygem_scope, dependent: :destroy
  has_one :ownership, through: :api_key_rubygem_scope
  # has_one :rubygem, through: :ownership

  validates :user, :name, :hashed_key, presence: true
  validate :exclusive_show_dashboard_scope, if: :can_show_dashboard?
  validate :scope_presence
  validates :name, length: { maximum: Gemcutter::MAX_FIELD_LENGTH }
  validate :gem_ownership

  attr_accessor :rubygem_name

  def enabled_scopes
    API_SCOPES.filter_map { |scope| scope if send(scope) }
  end

  API_SCOPES.each do |scope|
    define_method(:"can_#{scope}?") do
      scope_enabled = send(scope)
      return scope_enabled if !scope_enabled || new_record?
      touch :last_accessed_at
    end
  end

  def mfa_authorized?(otp)
    return true unless mfa_enabled?
    user.otp_verified?(otp)
  end

  def mfa_enabled?
    return false unless user.mfa_enabled?
    user.mfa_ui_and_api? || mfa
  end

  def api_authorized?
    gem_ownership
  end

  def rubygem=(rubygem)
    self.ownership = user.ownerships.find_by(rubygem: rubygem)
    errors.add :rubygem, "#{rubygem.name} cannot be scoped to this API key" if ownership.nil? && rubygem
  end

  def rubygem
    ownership&.rubygem
  end

  def invalid?
    !!invalid_at
  end

  private

  def exclusive_show_dashboard_scope
    errors.add :show_dashboard, "scope must be enabled exclusively" if other_enabled_scopes?
  end

  def other_enabled_scopes?
    enabled_scopes.tap { |scope| scope.delete(:show_dashboard) }.any?
  end

  def scope_presence
    errors.add :base, "Please enable at least one scope" unless enabled_scopes.any?
  end

  def set_rubygem_from_name
    return if rubygem_name.nil?
    # for update, set it back to all scopes
    return self.rubygem = nil if rubygem_name.blank?

    rubygem = Rubygem.name_is(rubygem_name).first
    errors.add :rubygem, "#{rubygem_name} could not be found" unless rubygem

    self.rubygem = rubygem
  end

  def gem_ownership
    return true unless rubygem
    return true if rubygem.owned_by?(user)
    errors.add :rubygem, "#{rubygem.name} cannot be scoped to this API key"
    false
  end
end

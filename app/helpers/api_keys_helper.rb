module ApiKeysHelper
  def gem_scope(api_key)
    return api_key.removed_rubygem_name if api_key.removed_rubygem_name.present?

    api_key.rubygem ? api_key.rubygem.name : "All gems"
  end
end

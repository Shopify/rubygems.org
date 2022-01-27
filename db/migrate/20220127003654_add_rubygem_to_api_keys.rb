class AddRubygemToApiKeys < ActiveRecord::Migration[6.1]
  def change
    add_reference :api_keys, :rubygem
  end
end

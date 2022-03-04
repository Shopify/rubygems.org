class AddInvalidAtToApiKeys < ActiveRecord::Migration[6.1]
  def change
    add_column :api_keys, :invalid_at, :datetime
  end
end

class AddRequireMfaAtToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :require_mfa_at, :datetime
  end
end

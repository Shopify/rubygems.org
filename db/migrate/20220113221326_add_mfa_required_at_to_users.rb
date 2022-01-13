class AddMfaRequiredAtToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :mfa_required_at, :datetime
  end
end

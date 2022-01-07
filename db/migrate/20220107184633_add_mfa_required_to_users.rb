class AddMfaRequiredToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :mfa_required, :boolean, default: false, null: false
  end
end

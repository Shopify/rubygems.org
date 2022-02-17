class AddAuthSecretToUser < ActiveRecord::Migration[6.1]
  def up
    add_column :users, :auth_secret, :string
  end

  def down
    remove_column :users, :auth_secret
  end
end

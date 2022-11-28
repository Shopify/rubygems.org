class AddWebAuthnTokenToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :webauthn_token, :string, limit: 128
    add_column :users, :webauthn_token_expires_at, :datetime
  end
end

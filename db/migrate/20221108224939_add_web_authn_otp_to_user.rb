class AddWebAuthnOtpToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :webauthn_otp, :string, limit: 128
    add_column :users, :webauthn_otp_expires_at, :datetime
  end
end

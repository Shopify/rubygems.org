# frozen_string_literal: true

class AddLocaleToUsers < ActiveRecord::Migration[8.1]
  def change
    # Preferred UI locale for a signed-in user. Null = no preference (follow the
    # URL / default). Safe to vary on because signed-in responses are not
    # shared-cached.
    add_column :users, :locale, :string
  end
end

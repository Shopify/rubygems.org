class CreateApiKeyRubygemScope < ActiveRecord::Migration[6.1]
  def change
    create_table :api_key_rubygem_scopes do |t|
      t.references :api_key, null: false
      t.references :ownership, null: false, index: false
    end
  end
end

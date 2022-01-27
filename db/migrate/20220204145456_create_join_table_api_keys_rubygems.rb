class CreateJoinTableApiKeysRubygems < ActiveRecord::Migration[6.1]
  def self.up
    create_table :api_keys_rubygems do |t|
      t.references :api_key
      t.references :rubygem, index: false
    end
  end

  def self.down
    drop_table :api_keys_rubygems
  end
end

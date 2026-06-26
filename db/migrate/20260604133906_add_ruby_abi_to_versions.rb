# frozen_string_literal: true

class AddRubyAbiToVersions < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    unless column_exists?(:versions, :ruby_abi)
      # Captures the single Ruby ABI a "skinny" content-addressable
      # binary targets (e.g. "3.3"). Empty for source gems and "fat" binaries, which
      # preserves the existing one-per-(number, platform) uniqueness for them.
      add_column :versions, :ruby_abi, :string, default: "", null: false
    end

    remove_index :versions,
      name: "index_versions_on_rubygem_id_and_number_and_platform",
      algorithm: :concurrently
    add_index :versions,
      %i[rubygem_id number platform ruby_abi],
      unique: true,
      name: "index_versions_on_rubygem_number_platform_ruby_abi",
      algorithm: :concurrently

    remove_index :versions,
      name: "index_versions_on_canonical_number_and_rubygem_id_and_platform",
      algorithm: :concurrently
    add_index :versions,
      %i[canonical_number rubygem_id platform ruby_abi],
      unique: true,
      name: "index_versions_on_canonical_rubygem_platform_ruby_abi",
      algorithm: :concurrently
  end

  def down
    remove_index :versions,
      name: "index_versions_on_rubygem_number_platform_ruby_abi",
      algorithm: :concurrently
    add_index :versions,
      %i[rubygem_id number platform],
      unique: true,
      name: "index_versions_on_rubygem_id_and_number_and_platform",
      algorithm: :concurrently

    remove_index :versions,
      name: "index_versions_on_canonical_rubygem_platform_ruby_abi",
      algorithm: :concurrently
    add_index :versions,
      %i[canonical_number rubygem_id platform],
      unique: true,
      name: "index_versions_on_canonical_number_and_rubygem_id_and_platform",
      algorithm: :concurrently

    remove_column :versions, :ruby_abi
  end
end

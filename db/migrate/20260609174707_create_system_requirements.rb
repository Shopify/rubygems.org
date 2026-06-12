# frozen_string_literal: true

class CreateSystemRequirements < ActiveRecord::Migration[8.1]
  def change
    # One row per (version, named system requirement). Mirrors how the compact
    # index requirements section already lists named version requirements
    # (ruby:, rubygems:) and how dependencies are stored in their own table.
    #
    # name:        "glibc", "libstdcxx", later "musl" / "darwin" / external libs
    # requirement: a Gem::Requirement string, e.g. ">= 2.34"
    #
    # Surfaced as `name:requirement` tokens in the v3 (content-addressable)
    # compact index so clients can skip an incompatible binary and fall back to
    # compiling from source.
    create_table :system_requirements do |t|
      t.references :version, null: false, foreign_key: true
      t.string :name, null: false
      t.string :requirement, null: false
      t.timestamps
    end

    add_index :system_requirements, %i[version_id name], unique: true
  end
end

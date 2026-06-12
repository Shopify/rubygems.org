# frozen_string_literal: true

# A named version requirement the install host must satisfy for a precompiled
# (content-addressable) binary to load — e.g. name "glibc", requirement ">= 2.34".
# Auto-derived at build time and carried via spec.metadata; emitted as a
# `name:requirement` token in the v3 compact index alongside ruby:/rubygems:.
class SystemRequirement < ApplicationRecord
  belongs_to :version

  validates :name, presence: true, uniqueness: { scope: :version_id }
  validates :requirement,
    presence: true,
    length: { maximum: Gemcutter::MAX_FIELD_LENGTH },
    gem_requirements: true
end

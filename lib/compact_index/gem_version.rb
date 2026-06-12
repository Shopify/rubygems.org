# frozen_string_literal: true

module CompactIndex
  module GemVersionMethods
    def number_and_platform
      if platform.nil? || platform == "ruby"
        number
      else
        "#{number}-#{platform}"
      end
    end

    def <=>(other)
      number_comp = number <=> other.number

      if number_comp.zero?
        [number, platform].compact <=> [other.number, other.platform].compact
      else
        number_comp
      end
    end

    def to_line
      line = "#{number_and_platform} #{deps_line}|checksum:#{checksum}"
      line << ",ruby:#{ruby_version_line}" if ruby_version && ruby_version != ">= 0"
      line << ",rubygems:#{rubygems_version_line}" if rubygems_version && rubygems_version != ">= 0"
      line
    end

    private

    def ruby_version_line
      join_multiple(ruby_version)
    end

    def rubygems_version_line
      join_multiple(rubygems_version)
    end

    def deps_line
      return "" if dependencies.nil?

      dependencies.map do |d|
        [d[:gem], join_multiple(d.version_and_platform)].join(":")
      end.join(",")
    end

    def join_multiple(requirements)
      requirements = requirements.split(", ")
      requirements.sort!
      requirements.join("&")
    end
  end

  GemVersion = Struct.new(:number, :platform, :checksum, :info_checksum,
                          :dependencies, :ruby_version, :rubygems_version) do
    include GemVersionMethods
  end

  GemVersionV2 = Struct.new(:number, :platform, :checksum, :info_checksum,
                            :dependencies, :ruby_version, :rubygems_version,
                            :created_at) do
    include GemVersionMethods

    def to_line
      line = super
      line << ",created_at:#{created_at}" if created_at
      line
    end
  end

  GemVersionV3 = Struct.new(:number, :platform, :checksum, :info_checksum,
                          :dependencies, :ruby_version, :rubygems_version,
                          :created_at, :ruby_minor, :system_requirements) do
    include GemVersionMethods

    def to_line
      line = super
      line << ",created_at:#{created_at}" if created_at
      line << ",platform:#{platform}" if platformed?
      # Named system requirements (glibc, libstdcxx, ...) apply to any precompiled
      # binary — fat or skinny. Clients compare each against the host and fall back
      # to a source build when unsatisfied. Rendered like ruby:/rubygems: — each as
      # a `name:requirement` token.
      if system_requirements.present? && platformed?
        system_requirements.each do |name, requirement|
          line << ",#{name}:#{join_multiple(requirement)}"
        end
      end
      line
    end

    def platformed?
      platform && platform != "ruby"
    end

    def content_addressed?
      platformed? && ruby_minor.present?
    end

    def number_and_platform
      return number unless platformed?

      if content_addressed?
        "#{number}-#{checksum&.first(10)}"
      else
        "#{number}-#{platform}"
      end
    end
  end
end

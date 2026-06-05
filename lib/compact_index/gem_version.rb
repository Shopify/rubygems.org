# frozen_string_literal: true

module CompactIndex
  module GemVersionMethods
    def number_and_platform
      if content_addressed?
        # Skinny (content-addressable) binaries are addressed by content: the
        # version string is "<number>-<sha10>" and the platform moves into the
        # requirements section (see #to_line).
        "#{number}-#{content_address}"
      elsif platform.nil? || platform == "ruby"
        number
      else
        "#{number}-#{platform}"
      end
    end

    def content_addressed?
      respond_to?(:content_address) && content_address.present?
    end

    def platformed?
      platform.present? && platform != "ruby"
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
      line << ",platform:= #{platform}" if platformed?
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
                          :dependencies, :ruby_version, :rubygems_version,
                          :content_address) do
    include GemVersionMethods
  end

  GemVersionV2 = Struct.new(:number, :platform, :checksum, :info_checksum,
                            :dependencies, :ruby_version, :rubygems_version,
                            :created_at, :content_address) do
    include GemVersionMethods

    def to_line
      line = super
      line << ",created_at:#{created_at}" if created_at
      line
    end
  end
end

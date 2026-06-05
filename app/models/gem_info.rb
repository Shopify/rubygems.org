# frozen_string_literal: true

class GemInfo
  VERSIONS = {
    1 => { cache_prefix: "info", stats_prefix: "compact_index.memcached.info", klass: CompactIndex::GemVersion,
           checksum_column: "info_checksum", yanked_checksum_column: "yanked_info_checksum" },
    2 => { cache_prefix: "info_v2", stats_prefix: "compact_index.memcached.info_v2", klass: CompactIndex::GemVersionV2,
           checksum_column: "info_checksum_v2", yanked_checksum_column: "yanked_info_checksum_v2" }
  }.freeze

  def initialize(rubygem_name, cached: true)
    @rubygem_name = rubygem_name
    @cached = cached
  end

  def compact_index_info(version: 1)
    config = VERSIONS.fetch(version)
    cache_key = "#{config[:cache_prefix]}/#{@rubygem_name}"
    stats_key = config[:stats_prefix]

    if @cached && (info = read_cache(cache_key))
      StatsD.increment "#{stats_key}.hit"
      info
    else
      StatsD.increment "#{stats_key}.miss"
      compute_compact_index_info(version:).tap do |result|
        Rails.cache.write(cache_key, result)
      end
    end
  end

  def info_checksum(version: 1)
    compact_index_info = CompactIndex.info(compute_compact_index_info(version:))
    Digest::MD5.hexdigest(compact_index_info)
  end

  def self.ordered_names(cached: true)
    if cached && (names = Rails.cache.read("names"))
      StatsD.increment "compact_index.memcached.names.hit"
    else
      StatsD.increment "compact_index.memcached.names.miss"
      names = Rubygem.with_versions.order(:name).pluck(:name)
      Rails.cache.write("names", names)
    end
    names
  end

  def self.compact_index_versions(date, version: 1)
    config = VERSIONS.fetch(version)
    checksum_column = config[:checksum_column]
    yanked_checksum_column = config[:yanked_checksum_column]

    query = ["(SELECT r.name, v.created_at as date, v.#{checksum_column} as info_checksum, v.number, v.platform, v.sha256, v.required_ruby_version
              FROM rubygems AS r, versions AS v
              WHERE v.rubygem_id = r.id AND
                    v.created_at > ?)
              UNION
              (SELECT r.name, v.yanked_at as date, v.#{yanked_checksum_column} as info_checksum, '-'||v.number, v.platform, v.sha256, v.required_ruby_version
              FROM rubygems AS r, versions AS v
              WHERE v.rubygem_id = r.id AND
                    v.indexed is false AND
                    v.yanked_at > ?)
              ORDER BY date, number, platform, name", date, date]

    map_gem_versions(execute_raw_sql(query).map { |v| [v["name"], [v]] }, version)
  end

  def self.compact_index_public_versions(updated_at, version: 1)
    config = VERSIONS.fetch(version)
    checksum_column = config[:checksum_column]
    yanked_checksum_column = config[:yanked_checksum_column]

    query = ["SELECT r.name, v.indexed, COALESCE(v.yanked_at, v.created_at) as stamp,
                     v.sha256, COALESCE(v.#{yanked_checksum_column}, v.#{checksum_column}) as info_checksum,
                     v.number, v.platform, v.required_ruby_version
              FROM rubygems AS r, versions AS v
              WHERE v.rubygem_id = r.id AND
                    (v.created_at <= ? OR v.yanked_at <= ?)
              ORDER BY r.name, stamp, v.number, v.platform", updated_at, updated_at]

    versions_by_gem = execute_raw_sql(query).group_by { |v| v["name"] }
    versions_by_gem.each_value do |versions|
      info_checksum = versions.last["info_checksum"]
      versions.select! { |v| v["indexed"] == true }
      # Set all versions' info_checksum to work around https://github.com/bundler/compact_index/pull/20
      versions.each { |v| v["info_checksum"] = info_checksum }
    end
    versions_by_gem.reject! { |_, versions| versions.empty? }

    map_gem_versions(versions_by_gem, version)
  end

  def self.execute_raw_sql(query)
    sanitized_sql = ActiveRecord::Base.send(:sanitize_sql_array, query)
    ActiveRecord::Base.connection.execute(sanitized_sql)
  end

  def self.map_gem_versions(versions_by_gem, serving_version = 1)
    versions_by_gem.filter_map do |gem_name, versions|
      compact_index_versions = versions.filter_map do |version|
        content_address = content_address_for_version(version["platform"], version["required_ruby_version"], version["sha256"])
        # Skinny (content-addressable) binaries are listed only in the v2 index;
        # the v1 index lists source and fat binaries so older clients are unaffected.
        next if content_address && serving_version < 2

        CompactIndex::GemVersion.new(version["number"],
          version["platform"],
          version["sha256"],
          version["info_checksum"],
          nil, nil, nil,
          content_address)
      end
      next if compact_index_versions.empty?
      CompactIndex::Gem.new(gem_name, compact_index_versions)
    end
  end

  # Class-level twin of #content_address_for, for the /versions file path which
  # works from raw SQL rows. Returns the 10-char content address for skinny
  # binaries, or nil for source/fat binaries.
  def self.content_address_for_version(platform, required_ruby_version, sha256)
    return if platform.blank? || platform == "ruby" || sha256.blank?
    return unless Version.skinny_ruby_minor(required_ruby_version)
    Version._sha256_hex(sha256)[0, 10]
  end

  private_class_method :map_gem_versions, :execute_raw_sql, :content_address_for_version

  private

  DEPENDENCY_NAMES_INDEX = 8

  DEPENDENCY_REQUIREMENTS_INDEX = 7

  # Marshal.load of pre-deploy cache entries fails when GemVersion grows a Struct field.
  def read_cache(cache_key)
    Rails.cache.read(cache_key)
  rescue TypeError
    nil
  end

  def compute_compact_index_info(version:)
    version_class = VERSIONS.dig(version, :klass)
    requirements_and_dependencies.filter_map do |row|
      number, platform, checksum, info_checksum, ruby_version, rubygems_version, created_at, = row
      checksum = Version._sha256_hex(checksum)
      content_address = content_address_for(platform:, ruby_version:, checksum:)

      # Skinny (content-addressable) binaries are served only from the v2 index.
      # The v1 index carries source and fat binaries so older clients (which would
      # misread the content address as a platform) are unaffected.
      next if content_address && version < 2

      created_at = created_at&.utc&.iso8601
      args = { number:, platform:, checksum:, info_checksum:, dependencies: build_dependencies(row),
               ruby_version:, rubygems_version:, created_at:, content_address: }
      version_class.new(**args.slice(*version_class.members))
    end
  end

  def build_dependencies(row)
    dependencies = []
    if row[DEPENDENCY_REQUIREMENTS_INDEX]
      reqs = row[DEPENDENCY_REQUIREMENTS_INDEX].split("@")
      dep_names = row[DEPENDENCY_NAMES_INDEX].split(",")
      raise "BUG: different size of reqs and dep_names." unless reqs.size == dep_names.size
      dep_names.zip(reqs).each do |name, req|
        dependencies << CompactIndex::Dependency.new(name, req) unless name == "0"
      end
    end
    dependencies
  end

  # Skinny (content-addressable) binaries are addressed by content in the compact
  # index: the version string becomes "<number>-<sha10>" and the platform is moved
  # into the requirements section. Returns the 10-char content address (matching
  # Version#full_name), or nil for source and fat binaries which keep the classic
  # number[-platform] addressing.
  def content_address_for(platform:, ruby_version:, checksum:)
    return if platform.blank? || platform == "ruby"
    return unless Version.skinny_ruby_minor(ruby_version)
    checksum[0, 10]
  end

  def requirements_and_dependencies
    @requirements_and_dependencies ||= fetch_requirements_and_dependencies
  end

  def fetch_requirements_and_dependencies
    group_by_columns = "number, platform, sha256, info_checksum, required_ruby_version, required_rubygems_version, versions.created_at"

    dep_req_agg = "string_agg(dependencies.requirements, '@' ORDER BY rubygems_dependencies.name, dependencies.id)"

    dep_name_agg = "string_agg(coalesce(rubygems_dependencies.name, '0'), ',' ORDER BY rubygems_dependencies.name) AS dep_name"

    Rubygem.joins("LEFT JOIN versions ON versions.rubygem_id = rubygems.id
        LEFT JOIN dependencies ON dependencies.version_id = versions.id
        LEFT JOIN rubygems rubygems_dependencies
          ON rubygems_dependencies.id = dependencies.rubygem_id
          AND dependencies.scope = 'runtime'")
      .where("rubygems.name = ? AND versions.indexed = true", @rubygem_name)
      .group(Arel.sql(group_by_columns))
      .order(Arel.sql("versions.created_at, number, platform, dep_name"))
      .pluck(Arel.sql("#{group_by_columns}, #{dep_req_agg}, #{dep_name_agg}"))
  end
end

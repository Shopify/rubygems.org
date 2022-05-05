# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `autoprefixer-rails` gem.
# Please instead update this file by running `bin/tapioca gem autoprefixer-rails`.

module AutoprefixedRails; end

class AutoprefixedRails::Railtie < ::Rails::Railtie
  def config; end
  def roots; end
end

# Ruby integration with Autoprefixer JS library, which parse CSS and adds
# only actual prefixed
module AutoprefixerRails
  class << self
    # Add Autoprefixer for Sprockets environment in `assets`.
    # You can specify `browsers` actual in your project.
    def install(assets, params = T.unsafe(nil)); end

    # Add prefixes to `css`. See `Processor#process` for options.
    def process(css, opts = T.unsafe(nil)); end

    # Cache processor instances
    def processor(params = T.unsafe(nil)); end

    # Disable installed Autoprefixer
    def uninstall(assets); end
  end
end

# Ruby to JS wrapper for Autoprefixer processor instance
class AutoprefixerRails::Processor
  # @return [Processor] a new instance of Processor
  def initialize(params = T.unsafe(nil)); end

  # Return, which browsers and prefixes will be used
  def info; end

  # Parse Browserslist config
  def parse_config(config); end

  # Process `css` and return result.
  #
  # Options can be:
  # * `from` with input CSS file name. Will be used in error messages.
  # * `to` with output CSS file name.
  # * `map` with true to generate new source map or with previous map.
  def process(css, opts = T.unsafe(nil)); end

  private

  def build_js; end

  # Convert ruby_options to jsOptions
  def convert_options(opts); end

  # Try to find Browserslist config
  def find_config(file); end

  def params_with_browsers(from = T.unsafe(nil)); end

  # Lazy load for JS library
  def runtime; end
end

AutoprefixerRails::Processor::SUPPORTED_RUNTIMES = T.let(T.unsafe(nil), Array)

# Container of prefixed CSS and source map with changes
class AutoprefixerRails::Result
  # @return [Result] a new instance of Result
  def initialize(css, map, warnings); end

  # Prefixed CSS after Autoprefixer
  def css; end

  # Source map of changes
  def map; end

  # Stringify prefixed CSS
  def to_s; end

  # Warnings from Autoprefixer
  def warnings; end
end

# Register autoprefixer postprocessor in Sprockets and fix common issues
class AutoprefixerRails::Sprockets
  # Sprockets 2 API new and render
  #
  # @return [Sprockets] a new instance of Sprockets
  def initialize(filename); end

  # Sprockets 2 API new and render
  def render(*_arg0); end

  class << self
    # Sprockets 3 and 4 API
    def call(input); end

    # Register postprocessor in Sprockets depend on issues with other gems
    def install(env); end

    def register_processor(processor); end

    # Add prefixes to `css`
    def run(filename, css); end

    # Register postprocessor in Sprockets depend on issues with other gems
    def uninstall(env); end
  end
end

AutoprefixerRails::VERSION = T.let(T.unsafe(nil), String)
IS_SECTION = T.let(T.unsafe(nil), Regexp)

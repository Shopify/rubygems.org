# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `uglifier` gem.
# Please instead update this file by running `bin/tapioca gem uglifier`.

# A wrapper around the UglifyJS interface
class Uglifier
  # Initialize new context for Uglifier with given options
  #
  # @param options [Hash] optional overrides to +Uglifier::DEFAULTS+
  # @return [Uglifier] a new instance of Uglifier
  def initialize(options = T.unsafe(nil)); end

  # Minifies JavaScript code
  #
  # @param source [IO, String] valid JS source code.
  # @return [String] minified code.
  def compile(source); end

  # Minifies JavaScript code and generates a source map
  #
  # @param source [IO, String] valid JS source code.
  # @return [Array(String, String)] minified code and source map.
  def compile_with_map(source); end

  # Minifies JavaScript code
  #
  # @param source [IO, String] valid JS source code.
  # @return [String] minified code.
  def compress(source); end

  private

  def comment_options; end
  def comment_setting; end
  def compressor_options; end
  def conditional_option(value, defaults, overrides = T.unsafe(nil)); end
  def context; end
  def context_lines_message(source, line_number, column); end
  def enclose_options; end
  def encode_regexp(regexp); end
  def error_context_format_options(low, high, line_index, column); end
  def error_context_lines; end
  def error_message(result, options); end
  def extract_source_mapping_url(source); end
  def format_error_line(line, options); end
  def format_lines(lines, options); end

  # @return [Boolean]
  def harmony?; end

  def harmony_error_message(message); end

  # @return [Boolean]
  def ie8?; end

  def input_source_map(source, generate_map); end

  # @return [Boolean]
  def keep_fnames?(type); end

  def mangle_options; end
  def mangle_properties_options; end
  def migrate_braces(options); end

  # Prevent negate_iife when wrap_iife is true
  def negate_iife_block; end

  def output_options; end
  def parse_options; end

  # @raise [Error]
  def parse_result(result, generate_map, options); end

  def parse_source_map_options; end
  def quote_style; end
  def read_source(source); end

  # Run UglifyJS for given source code
  def run_uglifyjs(input, generate_map); end

  def sanitize_map_root(map); end
  def source_map_comments; end
  def source_map_options(input_map); end
  def source_with(path); end

  class << self
    # Minifies JavaScript code using implicit context.
    #
    # @param source [IO, String] valid JS source code.
    # @param options [Hash] optional overrides to +Uglifier::DEFAULTS+
    # @return [String] minified code.
    def compile(source, options = T.unsafe(nil)); end

    # Minifies JavaScript code and generates a source map using implicit context.
    #
    # @param source [IO, String] valid JS source code.
    # @param options [Hash] optional overrides to +Uglifier::DEFAULTS+
    # @return [Array(String, String)] minified code and source map.
    def compile_with_map(source, options = T.unsafe(nil)); end
  end
end

# Default options for compilation
Uglifier::DEFAULTS = T.let(T.unsafe(nil), Hash)

# ES5 shims source path
Uglifier::ES5FallbackPath = T.let(T.unsafe(nil), String)

Uglifier::EXTRA_OPTIONS = T.let(T.unsafe(nil), Array)

# Error class for compilation errors.
class Uglifier::Error < ::StandardError; end

# UglifyJS with Harmony source path
Uglifier::HarmonySourcePath = T.let(T.unsafe(nil), String)

Uglifier::MANGLE_PROPERTIES_DEFAULTS = T.let(T.unsafe(nil), Hash)
Uglifier::SOURCE_MAP_DEFAULTS = T.let(T.unsafe(nil), Hash)

# Source Map path
Uglifier::SourceMapPath = T.let(T.unsafe(nil), String)

# UglifyJS source path
Uglifier::SourcePath = T.let(T.unsafe(nil), String)

# String.split shim source path
Uglifier::SplitFallbackPath = T.let(T.unsafe(nil), String)

# UglifyJS wrapper path
Uglifier::UglifyJSWrapperPath = T.let(T.unsafe(nil), String)

# Current version of Uglifier.
Uglifier::VERSION = T.let(T.unsafe(nil), String)

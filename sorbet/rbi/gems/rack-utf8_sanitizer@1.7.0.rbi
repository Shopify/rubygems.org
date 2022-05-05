# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `rack-utf8_sanitizer` gem.
# Please instead update this file by running `bin/tapioca gem rack-utf8_sanitizer`.

# Rack::Attack::Request is the same as ::Rack::Request by default.
#
# This is a safe place to add custom helper methods to the request object
# through monkey patching:
#
#   class Rack::Attack::Request < ::Rack::Request
#     def localhost?
#       ip == "127.0.0.1"
#     end
#   end
#
#   Rack::Attack.safelist("localhost") {|req| req.localhost? }
module Rack
  class << self
    def release; end
    def version; end
  end
end

Rack::CACHE_CONTROL = T.let(T.unsafe(nil), String)
Rack::CONTENT_LENGTH = T.let(T.unsafe(nil), String)
Rack::CONTENT_TYPE = T.let(T.unsafe(nil), String)
Rack::DELETE = T.let(T.unsafe(nil), String)
Rack::ETAG = T.let(T.unsafe(nil), String)
Rack::EXPIRES = T.let(T.unsafe(nil), String)
Rack::File = Rack::Files
Rack::GET = T.let(T.unsafe(nil), String)
Rack::HEAD = T.let(T.unsafe(nil), String)
Rack::HTTPS = T.let(T.unsafe(nil), String)
Rack::HTTP_COOKIE = T.let(T.unsafe(nil), String)
Rack::HTTP_HOST = T.let(T.unsafe(nil), String)
Rack::HTTP_PORT = T.let(T.unsafe(nil), String)
Rack::HTTP_VERSION = T.let(T.unsafe(nil), String)
Rack::LINK = T.let(T.unsafe(nil), String)
Rack::OPTIONS = T.let(T.unsafe(nil), String)
Rack::PATCH = T.let(T.unsafe(nil), String)
Rack::PATH_INFO = T.let(T.unsafe(nil), String)
Rack::POST = T.let(T.unsafe(nil), String)
Rack::PUT = T.let(T.unsafe(nil), String)
Rack::QUERY_STRING = T.let(T.unsafe(nil), String)
Rack::RACK_ERRORS = T.let(T.unsafe(nil), String)
Rack::RACK_HIJACK = T.let(T.unsafe(nil), String)
Rack::RACK_HIJACK_IO = T.let(T.unsafe(nil), String)
Rack::RACK_INPUT = T.let(T.unsafe(nil), String)
Rack::RACK_IS_HIJACK = T.let(T.unsafe(nil), String)
Rack::RACK_LOGGER = T.let(T.unsafe(nil), String)
Rack::RACK_METHODOVERRIDE_ORIGINAL_METHOD = T.let(T.unsafe(nil), String)
Rack::RACK_MULTIPART_BUFFER_SIZE = T.let(T.unsafe(nil), String)
Rack::RACK_MULTIPART_TEMPFILE_FACTORY = T.let(T.unsafe(nil), String)
Rack::RACK_MULTIPROCESS = T.let(T.unsafe(nil), String)
Rack::RACK_MULTITHREAD = T.let(T.unsafe(nil), String)
Rack::RACK_RECURSIVE_INCLUDE = T.let(T.unsafe(nil), String)
Rack::RACK_REQUEST_COOKIE_HASH = T.let(T.unsafe(nil), String)
Rack::RACK_REQUEST_COOKIE_STRING = T.let(T.unsafe(nil), String)
Rack::RACK_REQUEST_FORM_HASH = T.let(T.unsafe(nil), String)
Rack::RACK_REQUEST_FORM_INPUT = T.let(T.unsafe(nil), String)
Rack::RACK_REQUEST_FORM_VARS = T.let(T.unsafe(nil), String)
Rack::RACK_REQUEST_QUERY_HASH = T.let(T.unsafe(nil), String)
Rack::RACK_REQUEST_QUERY_STRING = T.let(T.unsafe(nil), String)
Rack::RACK_RUNONCE = T.let(T.unsafe(nil), String)
Rack::RACK_SESSION = T.let(T.unsafe(nil), String)
Rack::RACK_SESSION_OPTIONS = T.let(T.unsafe(nil), String)
Rack::RACK_SESSION_UNPACKED_COOKIE_DATA = T.let(T.unsafe(nil), String)
Rack::RACK_SHOWSTATUS_DETAIL = T.let(T.unsafe(nil), String)
Rack::RACK_TEMPFILES = T.let(T.unsafe(nil), String)
Rack::RACK_URL_SCHEME = T.let(T.unsafe(nil), String)
Rack::RACK_VERSION = T.let(T.unsafe(nil), String)
Rack::RELEASE = T.let(T.unsafe(nil), String)
Rack::REQUEST_METHOD = T.let(T.unsafe(nil), String)
Rack::REQUEST_PATH = T.let(T.unsafe(nil), String)
Rack::SCRIPT_NAME = T.let(T.unsafe(nil), String)
Rack::SERVER_NAME = T.let(T.unsafe(nil), String)
Rack::SERVER_PORT = T.let(T.unsafe(nil), String)
Rack::SERVER_PROTOCOL = T.let(T.unsafe(nil), String)
Rack::SET_COOKIE = T.let(T.unsafe(nil), String)
Rack::TRACE = T.let(T.unsafe(nil), String)
Rack::TRANSFER_ENCODING = T.let(T.unsafe(nil), String)
Rack::UNLINK = T.let(T.unsafe(nil), String)

class Rack::UTF8Sanitizer
  # options[:sanitizable_content_types] Array
  # options[:additional_content_types] Array
  #
  # @return [UTF8Sanitizer] a new instance of UTF8Sanitizer
  def initialize(app, options = T.unsafe(nil)); end

  def call(env); end
  def sanitize(env); end

  protected

  def build_strategy(options); end
  def decode_string(input); end

  # Performs the reverse function of `unescape_unreserved`. Unlike
  # the previous function, we can reuse the logic in URI#encode
  def escape_unreserved(input); end

  def reencode_string(decoded_value); end

  # Cookies need to be split and then sanitized as url encoded strings
  # since the cookie string itself is not url encoded (separated by `;`),
  # and the normal method of `sanitize_uri_encoded_string` would break
  # later cookie parsing in the case that a cookie value contained an
  # encoded `;`.
  def sanitize_cookies(env); end

  def sanitize_io(io, uri_encoded = T.unsafe(nil)); end
  def sanitize_rack_input(env); end
  def sanitize_string(input); end

  # URI.encode/decode expect the input to be in ASCII-8BIT.
  # However, there could be invalid UTF-8 characters both in
  # raw and percent-encoded form.
  #
  # So, first sanitize the value, then percent-decode it while
  # treating as UTF-8, then sanitize the result and encode it back.
  #
  # The result is guaranteed to be UTF-8-safe.
  def sanitize_uri_encoded_string(input); end

  # @return [Boolean]
  def skip?(rack_env_key); end

  def strip_byte_order_mark(input); end
  def transfer_frozen(from, to); end

  # RFC3986, 2.2 states that the characters from 'reserved' group must be
  # protected during normalization (which is what UTF8Sanitizer does).
  #
  # However, the regexp approach used by URI.unescape is not sophisticated
  # enough for our task.
  def unescape_unreserved(input); end
end

Rack::UTF8Sanitizer::DEFAULT_STRATEGIES = T.let(T.unsafe(nil), Hash)
Rack::UTF8Sanitizer::HTTP_ = T.let(T.unsafe(nil), String)
Rack::UTF8Sanitizer::SANITIZABLE_CONTENT_TYPES = T.let(T.unsafe(nil), Array)

# Modeled after Rack::RewindableInput
# TODO: Should this delegate any methods to the original io?
class Rack::UTF8Sanitizer::SanitizedRackInput
  # @return [SanitizedRackInput] a new instance of SanitizedRackInput
  def initialize(original_io, sanitized_io); end

  def close; end
  def each(&block); end
  def gets; end
  def read(*args); end
  def rewind; end
  def size; end
end

Rack::UTF8Sanitizer::StringIO = StringIO

# This regexp matches all 'unreserved' characters from RFC3986 (2.3),
# plus all multibyte UTF-8 characters.
Rack::UTF8Sanitizer::UNRESERVED_OR_UTF8 = T.let(T.unsafe(nil), Regexp)

# This regexp matches unsafe characters, i.e. everything except 'reserved'
# and 'unreserved' characters from RFC3986 (2.3), and additionally '%',
# as percent-encoded unreserved characters could be left over from the
# `unescape_unreserved` invocation.
#
# See also URI::REGEXP::PATTERN::{UNRESERVED,RESERVED}.
Rack::UTF8Sanitizer::UNSAFE = T.let(T.unsafe(nil), Regexp)

Rack::UTF8Sanitizer::URI_ENCODED_CONTENT_TYPES = T.let(T.unsafe(nil), Array)

# http://rack.rubyforge.org/doc/SPEC.html
Rack::UTF8Sanitizer::URI_FIELDS = T.let(T.unsafe(nil), Array)

Rack::UTF8Sanitizer::UTF8_BOM = T.let(T.unsafe(nil), String)
Rack::UTF8Sanitizer::UTF8_BOM_SIZE = T.let(T.unsafe(nil), Integer)
Rack::VERSION = T.let(T.unsafe(nil), Array)

# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `faraday-httpclient` gem.
# Please instead update this file by running `bin/tapioca gem faraday-httpclient`.

module Faraday
  class << self
    def default_adapter; end
    def default_adapter=(adapter); end
    def default_connection; end
    def default_connection=(_arg0); end
    def default_connection_options; end
    def default_connection_options=(options); end
    def ignore_env_proxy; end
    def ignore_env_proxy=(_arg0); end
    def lib_path; end
    def lib_path=(_arg0); end
    def new(url = T.unsafe(nil), options = T.unsafe(nil), &block); end
    def require_lib(*libs); end
    def require_libs(*libs); end
    def respond_to_missing?(symbol, include_private = T.unsafe(nil)); end
    def root_path; end
    def root_path=(_arg0); end

    private

    def method_missing(name, *args, &block); end
  end
end

class Faraday::Adapter
  extend ::Faraday::MiddlewareRegistry
  extend ::Faraday::DependencyLoader
  extend ::Faraday::Adapter::Parallelism
  extend ::Faraday::AutoloadHelper

  def initialize(_app = T.unsafe(nil), opts = T.unsafe(nil), &block); end

  def call(env); end
  def close; end
  def connection(env); end

  private

  def request_timeout(type, options); end
  def save_response(env, status, body, headers = T.unsafe(nil), reason_phrase = T.unsafe(nil)); end
end

Faraday::Adapter::CONTENT_LENGTH = T.let(T.unsafe(nil), String)

# This class provides the main implementation for your adapter.
# There are some key responsibilities that your adapter should satisfy:
# * Initialize and store internally the client you chose (e.g. Net::HTTP)
# * Process requests and save the response (see `#call`)
class Faraday::Adapter::HTTPClient < ::Faraday::Adapter
  def build_connection(env); end
  def call(env); end
  def configure_client(client); end

  # Configure proxy URI and any user credentials.
  #
  # @param proxy [Hash]
  def configure_proxy(client, proxy); end

  # @param bind [Hash]
  def configure_socket(client, bind); end

  # @param ssl [Hash]
  def configure_ssl(client, ssl); end

  # @param req [Hash]
  def configure_timeouts(client, req); end

  # @param ssl [Hash]
  # @return [OpenSSL::X509::Store]
  def ssl_cert_store(ssl); end

  # @param ssl [Hash]
  def ssl_verify_mode(ssl); end
end

Faraday::Adapter::TIMEOUT_KEYS = T.let(T.unsafe(nil), Hash)
Faraday::CONTENT_TYPE = T.let(T.unsafe(nil), String)
Faraday::CompositeReadIO = Faraday::Multipart::CompositeReadIO
Faraday::FilePart = UploadIO

# Main Faraday::HTTPClient module
module Faraday::HTTPClient; end

Faraday::HTTPClient::VERSION = T.let(T.unsafe(nil), String)
Faraday::METHODS_WITH_BODY = T.let(T.unsafe(nil), Array)
Faraday::METHODS_WITH_QUERY = T.let(T.unsafe(nil), Array)
Faraday::ParamPart = Faraday::Multipart::ParamPart
Faraday::Parts = Parts
Faraday::Timer = Timeout
Faraday::UploadIO = UploadIO
Faraday::VERSION = T.let(T.unsafe(nil), String)

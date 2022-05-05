# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `faraday-net_http` gem.
# Please instead update this file by running `bin/tapioca gem faraday-net_http`.

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

class Faraday::Adapter::NetHttp < ::Faraday::Adapter
  # @return [NetHttp] a new instance of NetHttp
  def initialize(app = T.unsafe(nil), opts = T.unsafe(nil), &block); end

  def build_connection(env); end
  def call(env); end
  def net_http_connection(env); end

  private

  def configure_request(http, req); end
  def configure_ssl(http, ssl); end
  def create_request(env); end
  def perform_request(http, env); end
  def request_via_get_method(http, env, &block); end
  def request_via_request_method(http, env, &block); end
  def request_with_wrapped_block(http, env, &block); end
  def ssl_cert_store(ssl); end
  def ssl_verify_mode(ssl); end
end

Faraday::Adapter::NetHttp::NET_HTTP_EXCEPTIONS = T.let(T.unsafe(nil), Array)
Faraday::Adapter::TIMEOUT_KEYS = T.let(T.unsafe(nil), Hash)
Faraday::CONTENT_TYPE = T.let(T.unsafe(nil), String)
Faraday::CompositeReadIO = Faraday::Multipart::CompositeReadIO

# Aliases for Faraday v1, these are all deprecated and will be removed in v2 of this middleware
Faraday::FilePart = UploadIO

Faraday::METHODS_WITH_BODY = T.let(T.unsafe(nil), Array)
Faraday::METHODS_WITH_QUERY = T.let(T.unsafe(nil), Array)
module Faraday::NetHttp; end
Faraday::NetHttp::VERSION = T.let(T.unsafe(nil), String)
Faraday::ParamPart = Faraday::Multipart::ParamPart
Faraday::Parts = Parts
Faraday::Timer = Timeout
Faraday::UploadIO = UploadIO
Faraday::VERSION = T.let(T.unsafe(nil), String)

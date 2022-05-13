# typed: strict
class GithubSecretScanning
  extend T::Sig
  KEYS_URI = T.let("https://api.github.com/meta/public_keys/secret_scanning".freeze, String)

  sig { params(key_identifier: String).void }
  def initialize(key_identifier)
    @public_key = T.let(self.class.public_key(key_identifier), T.nilable(String))
  end

  sig { params(signature: String, body: String).returns(T::Boolean) }
  def valid_github_signature?(signature, body)
    return false if @public_key.blank?
    openssl_key = OpenSSL::PKey::EC.new(@public_key)
    openssl_key.verify(OpenSSL::Digest.new("SHA256"), Base64.decode64(signature), body)
  end

  sig { returns(T::Boolean) }
  def empty_public_key?
    @public_key.blank?
  end

  sig { params(id: String).returns(T.nilable(String)) }
  def self.public_key(id)
    cache_key = ["GithubSecretScanning", "public_keys", id]
    Rails.cache.fetch(cache_key) do
      public_keys = JSON.parse(secret_scanning_keys)["public_keys"]
      public_keys&.find { |v| v["key_identifier"] == id }&.fetch("key")
    end
  end

  sig { returns(String) }
  def self.secret_scanning_keys
    RestClient.get(KEYS_URI).body
  end
end

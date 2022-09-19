WebAuthn.configure do |config|
  config.origin = ENV.fetch("WEBAUTHN_ORIGIN", "http://localhost:3000")
  config.rp_name = "RubyGems.org"
end

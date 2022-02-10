module WebauthnHelpers
  def self.create_result(client:, challenge: nil)
    rp_id = URI.parse(client.origin).host

    result = client.create(
      challenge: challenge ?
        Base64.urlsafe_decode64(challenge) :
        SecureRandom.random_bytes(32),
      rp_id: rp_id
    )

    result["rawId"] = Base64.urlsafe_encode64(result["rawId"])
    result["response"]["attestationObject"] =
      Base64.urlsafe_encode64(result["response"]["attestationObject"])
    result["response"]["clientDataJSON"] =
      Base64.urlsafe_encode64(result["response"]["clientDataJSON"])
    result
  end

  def self.create(webauthn_credential:, client:)
    rp_id = URI.parse(client.origin).host
    credential = create_result(client: client)
    response = WebAuthn::Credential.from_create(credential)
    webauthn_credential.update!(
      external_id: response.id,
      public_key: response.public_key,
      sign_count: response.sign_count
    )
  end

  def self.get_result(client:, challenge:)
    result = client.get(challenge: Base64.urlsafe_decode64(challenge))
    result["rawId"] = Base64.urlsafe_encode64(result["rawId"])
    result["response"]["authenticatorData"] =
      Base64.urlsafe_encode64(result["response"]["authenticatorData"])
    result["response"]["clientDataJSON"] =
      Base64.urlsafe_encode64(result["response"]["clientDataJSON"])
    result["response"]["signature"] =
      Base64.urlsafe_encode64(result["response"]["signature"])
    result
  end
end

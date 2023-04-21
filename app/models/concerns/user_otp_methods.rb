module UserOtpMethods
  def disable_otp!
    if self.webauthn_credentials.none?
      mfa_disabled!
    end
    self.otp_seed = ""
    self.mfa_recovery_codes = []
    save!(validate: false)
  end

  def verify_and_enable_otp!(seed, level, otp, expiry)
    if expiry < Time.now.utc
      errors.add(:base, I18n.t("multifactor_auths.create.qrcode_expired"))
    elsif verify_digit_otp(seed, otp)
      enable_otp!(seed, level)
    else
      errors.add(:base, I18n.t("multifactor_auths.incorrect_otp"))
    end
  end

  def enable_otp!(seed, level)
    self.mfa_level = level
    self.otp_seed = seed
    self.mfa_recovery_codes = Array.new(10).map { SecureRandom.hex(6) }
    save!(validate: false)
  end

  def verify_digit_otp(seed, otp)
    return false if seed.blank?

    totp = ROTP::TOTP.new(seed)
    return false unless totp.verify(otp, drift_behind: 30, drift_ahead: 30)

    save!(validate: false)
  end
end

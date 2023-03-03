module UserTotpMethods
  extend ActiveSupport::Concern

  included do
    def disable_totp!
      mfa_disabled!
      self.mfa_seed = ""
      self.mfa_recovery_codes = []
      save!(validate: false)
    end

    def verify_and_enable_totp!(seed, level, otp, expiry)
      if expiry < Time.now.utc
        errors.add(:base, I18n.t("multifactor_auths.create.qrcode_expired"))
      elsif verify_totp(seed, otp)
        enable_mfa!(seed, level)
      else
        errors.add(:base, I18n.t("multifactor_auths.incorrect_otp"))
      end
    end

    def enable_totp!(seed, level)
      self.mfa_level = level
      self.mfa_seed = seed
      self.mfa_recovery_codes = Array.new(10).map { SecureRandom.hex(6) }
      save!(validate: false)
    end

    def verify_totp(seed, otp)
      totp = ROTP::TOTP.new(seed)
      return false unless totp.verify(otp, drift_behind: 30, drift_ahead: 30)

      save!(validate: false)
    end
  end
end

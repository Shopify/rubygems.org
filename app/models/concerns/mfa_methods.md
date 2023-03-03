### All methods
mfa_enabled?
disable_totp!
verify_and_enable_mfa!
enable_mfa!
mfa_gem_signin_authorized?
mfa_recommended_not_yet_enabled?
mfa_recommended_weak_level_enabled?
mfa_required_not_yet_enabled?
mfa_required_weak_level_enabled?
ui_otp_verified?(otp)
api_otp_verified?(otp)

private

strong_mfa_level?
mfa_recommended?
mfa_required?
verify_digit_otp(seed, otp)
verify_webauthn_otp(otp)

class
without_mfa


### Methods that are totp based
disable_totp!
verify_and_enable_mfa!
enable_mfa!
verify_digit_otp(seed, otp)

disable_totp!
verify_and_enable_totp!
enable_totp!
verify_totp(seed, otp)

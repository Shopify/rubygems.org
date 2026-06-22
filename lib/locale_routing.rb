# frozen_string_literal: true

# Single source of truth for path-based locale routing.
#
# Centralises: the supported-locale allowlist, the route path constraint, locale
# normalisation, and the (security-sensitive) default-locale strip redirect.
# Keeping all of this in one place is deliberate — locale resolution and the
# redirect target construction are the two spots most prone to subtle bugs.
module LocaleRouting
  DEFAULT_LOCALE = I18n.default_locale.to_s.freeze
  SUPPORTED_LOCALES = I18n.available_locales.map(&:to_s).freeze
  # URL locale segments are always lowercase (zh-cn, pt-br); the canonical I18n
  # locales keep their BCP-47 casing (zh-CN, pt-BR). This keeps URLs conventional
  # and avoids cache fragmentation between /zh-CN and /zh-cn.
  URL_LOCALES = SUPPORTED_LOCALES.map(&:downcase).freeze

  # Route constraint for the optional "(:locale)" path segment. Includes the
  # default locale so "/en/..." still *matches* a route; the controller then
  # redirects it to the unprefixed canonical (see ApplicationController#
  # strip_default_locale). Regexp.union groups + escapes the alternatives.
  PATH_CONSTRAINT = Regexp.union(URL_LOCALES)

  # Whether path-based locale routing is live. Gated by a *global* flag because
  # responses are cached by URL — see FeatureFlag::PATH_BASED_LOCALES. When off,
  # the site behaves as English-only (no hreflang alternates, no switcher) even
  # though the optional (:locale) routes still resolve.
  def self.path_based?
    FeatureFlag.enabled?(FeatureFlag::PATH_BASED_LOCALES)
  end

  def self.default_locale?(locale)
    locale.to_s.casecmp?(DEFAULT_LOCALE)
  end

  def self.supported?(locale)
    SUPPORTED_LOCALES.any? { |l| l.casecmp?(locale.to_s) }
  end

  # Map a (lowercase) URL locale segment back to its canonical I18n locale,
  # e.g. "zh-cn" -> "zh-CN". Returns nil for blank/unknown input.
  def self.i18n_locale(url_locale)
    return if url_locale.blank?
    SUPPORTED_LOCALES.find { |l| l.casecmp?(url_locale.to_s) }
  end

  # The :locale URL param for a given locale: nil for blank or the default locale
  # (so it is omitted from the path) and the lowercase URL form otherwise.
  def self.locale_param(locale)
    return if locale.blank? || default_locale?(locale)
    locale.to_s.downcase
  end

  # Redirect lambda that preserves the request's locale prefix on a fixed,
  # server-controlled target path (e.g. an onboarding step). `path` is always a
  # literal, so there is no user data in the Location. The default locale is
  # dropped (locale_param) so it stays unprefixed.
  def self.localized_redirect(path)
    lambda { |params, _request|
      locale = locale_param(params[:locale])
      locale ? "/#{locale}#{path}" : path
    }
  end

end

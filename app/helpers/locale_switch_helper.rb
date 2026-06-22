# frozen_string_literal: true

# Canonical + hreflang <link> tags for localized pages, plus the language switcher.
#
# One source of truth for the SEO link tags. Pages that need a page-specific
# canonical (e.g. a gem page pointing at its latest version, or a noindex page)
# render their own via `content_for :canonical`; the layout chooses between the
# two. This is intentionally NOT keyed off `content_for?(:head)` — unrelated head
# content must not suppress the canonical tags.
module LocaleSwitchHelper
  # Default canonical/hreflang block for the current page. No-op until path-based
  # locales are enabled, so the dark-launch state is byte-identical to today
  # (pages that want their own canonical still render it via content_for :canonical).
  def default_locale_link_tags
    return unless LocaleRouting.path_based?
    return unless request.get? || request.head?
    # Don't assert a canonical for filtered/paginated/query URLs: a path-only
    # self-referential canonical would wrongly collapse e.g. /gems?page=2 onto
    # /gems. Such pages are simply left without a canonical directive.
    return if request.query_string.present?

    canonical_link_tags { |locale| localized_url_for_current_page(locale) }
  end

  # Builds <link rel="canonical"> plus, when path-based locales are enabled,
  # per-locale hreflang alternates and an x-default pointing at the default
  # locale. The block receives a locale and must return the absolute URL for the
  # page in that locale.
  #
  # The canonical is self-referential (points at the current locale) — the
  # Google-recommended pattern when pages are clustered via hreflang. x-default
  # always points at the default locale.
  def canonical_link_tags(canonical_locale: I18n.locale)
    canonical = tag.link(rel: "canonical", href: yield(canonical_locale))
    return canonical unless LocaleRouting.path_based?

    alternates = I18n.available_locales.map do |locale|
      tag.link(rel: "alternate", hreflang: locale, href: yield(locale))
    end
    x_default = tag.link(rel: "alternate", hreflang: "x-default", href: yield(I18n.default_locale))

    safe_join([canonical, *alternates, x_default], "\n")
  end

  # Link to the current page in another locale, used by the footer switcher.
  def locale_switch_path(locale)
    url_for(request.path_parameters.merge(locale: LocaleRouting.locale_param(locale), only_path: true))
  end

  def locale_param(locale)
    LocaleRouting.locale_param(locale)
  end

  private

  def localized_url_for_current_page(locale = I18n.locale)
    url_for(request.path_parameters.merge(locale: LocaleRouting.locale_param(locale), only_path: false))
  end
end

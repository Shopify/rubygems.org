# frozen_string_literal: true

require "test_helper"

class LocaleRoutingTest < ActionDispatch::IntegrationTest
  setup do
    @rubygem = create(:rubygem, name: "sandworm", number: "1.0.0")
  end

  # --- locale resolution (flag-independent: the optional scope always resolves) ---

  test "paths without a locale prefix use the default locale" do
    get "/"

    assert_response :success
    assert_includes response.body, %(<html lang="en")
  end

  test "a non-default locale is taken from the URL path" do
    get "/de"

    assert_response :success
    assert_includes response.body, %(<html lang="de")
  end

  test "a query-string locale is ignored (cannot vary cached content)" do
    get "/?locale=de"

    assert_response :success
    assert_includes response.body, %(<html lang="en")
  end

  test "an unsupported locale path does not match the localized routes" do
    assert_raises(ActionController::RoutingError) { get "/xx/gems/sandworm" }
  end

  test "API routes are not affected by the locale scope" do
    assert_raises(ActionController::RoutingError) { get "/de/api/v1/gems/sandworm.json" }
  end

  # --- default-locale strip + open-redirect safety ---

  test "the default locale prefix 301s to the unprefixed canonical path" do
    get "/en/gems/sandworm"

    assert_response :moved_permanently
    assert_redirected_to "/gems/sandworm"
  end

  test "the default locale strip preserves the query string" do
    get "/en/search?query=rails"

    assert_response :moved_permanently
    assert_redirected_to "/search?query=rails"
  end

  test "the default locale strip can never produce an external redirect" do
    # No wildcard route builds the target from a raw path anymore, so a
    # percent-encoded slash just fails to match a route rather than redirecting.
    get "/en/%2F%2Fevil.com"

    if response.redirect?
      location = response.headers["Location"].to_s
      refute location.match?(%r{\A(https?:)?//}), "leaked an external/protocol-relative redirect: #{location}"
    end
  end

  # --- caching: locale must not leak as a query param onto un-localized routes ---

  test "a localized gem page never emits ?locale= query params (API/asset links stay cacheable)" do
    get "/de/gems/sandworm"

    assert_response :success
    refute_includes response.body, "?locale=", "locale leaked as a query param, fragmenting the CDN cache"
  end

  # --- SEO link tags, gated by the flag ---

  context "with path-based locales enabled" do
    setup { FeatureFlag.enable_globally(FeatureFlag::PATH_BASED_LOCALES) }
    teardown { FeatureFlag.disable_globally(FeatureFlag::PATH_BASED_LOCALES) }

    test "localized pages emit a self-referential canonical plus hreflang alternates" do
      get "/de"

      assert_response :success
      # self-referential canonical (current locale)
      assert page.has_css?(%(link[rel="canonical"][href="http://localhost/de"]), visible: false)
      # one alternate per available locale, plus x-default
      alternates = page.all(:css, %(link[rel="alternate"][hreflang]), visible: false)
      assert_equal I18n.available_locales.length + 1, alternates.length
      assert page.has_css?(%(link[rel="alternate"][hreflang="x-default"][href="http://localhost/"]), visible: false)
    end

    test "the footer language switcher is rendered" do
      get "/"

      assert_response :success
      assert page.has_link?(I18n.t(:locale_name, locale: :de), href: "/de")
    end
  end

  context "with path-based locales disabled (default)" do
    test "no hreflang alternates and no switcher are rendered" do
      get "/"

      assert_response :success
      refute page.has_css?(%(link[rel="alternate"][hreflang]), visible: false)
    end
  end
end

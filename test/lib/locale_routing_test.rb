# frozen_string_literal: true

require "test_helper"

class LocaleRoutingTest < ActiveSupport::TestCase
  context ".default_locale? / .supported?" do
    should "recognise the default locale" do
      assert LocaleRouting.default_locale?(I18n.default_locale)
      assert LocaleRouting.default_locale?(LocaleRouting::DEFAULT_LOCALE)
      refute LocaleRouting.default_locale?(:de)
    end

    should "recognise supported locales" do
      assert LocaleRouting.supported?(I18n.available_locales.first)
      refute LocaleRouting.supported?(:xx)
    end
  end

  context ".locale_param" do
    should "omit the default locale and lowercase the URL form of others" do
      assert_nil LocaleRouting.locale_param(I18n.default_locale)
      assert_equal "de", LocaleRouting.locale_param(:de)
      assert_equal "zh-cn", LocaleRouting.locale_param(:"zh-CN")
    end
  end

  context ".i18n_locale" do
    should "map a lowercase URL segment back to the canonical I18n locale" do
      assert_equal "zh-CN", LocaleRouting.i18n_locale("zh-cn")
      assert_equal "de", LocaleRouting.i18n_locale("de")
      assert_nil LocaleRouting.i18n_locale("xx")
      assert_nil LocaleRouting.i18n_locale(nil)
    end
  end

  context ".path_constraint" do
    should "match lowercase URL locales including the default and regions" do
      assert_match LocaleRouting::PATH_CONSTRAINT, "de"
      assert_match LocaleRouting::PATH_CONSTRAINT, "zh-cn"
      assert_match LocaleRouting::PATH_CONSTRAINT, LocaleRouting::DEFAULT_LOCALE
    end
  end

  context ".localized_redirect" do
    setup { @redirect = LocaleRouting.localized_redirect("/gems/transfer/organization") }

    should "keep a non-default locale prefix" do
      assert_equal "/de/gems/transfer/organization", @redirect.call({ locale: "de" }, nil)
    end

    should "drop the default locale prefix" do
      assert_equal "/gems/transfer/organization", @redirect.call({ locale: LocaleRouting::DEFAULT_LOCALE }, nil)
    end

    should "stay unprefixed when there is no locale" do
      assert_equal "/gems/transfer/organization", @redirect.call({ locale: nil }, nil)
    end
  end
end

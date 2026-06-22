# frozen_string_literal: true

require "test_helper"

# Emails render in the recipient's saved locale (see ApplicationMailer#with_locale_for).
class MailerLocaleTest < ActionMailer::TestCase
  def subject_for(locale)
    I18n.t("mailer.email_reset_update.subject", host: Gemcutter::HOST_DISPLAY, locale: locale)
  end

  should "render the subject in the recipient's preferred locale" do
    user = create(:user, locale: "de")

    email = Mailer.email_reset_update(user)

    assert_equal subject_for(:de), email.subject
    refute_equal subject_for(:en), email.subject
  end

  should "fall back to the default locale when the recipient has no preference" do
    user = create(:user, locale: nil)

    email = Mailer.email_reset_update(user)

    assert_equal subject_for(I18n.default_locale), email.subject
  end

  should "not leak the recipient locale into the global I18n.locale" do
    user = create(:user, locale: "de")

    Mailer.email_reset_update(user).subject

    assert_equal I18n.default_locale, I18n.locale
  end
end

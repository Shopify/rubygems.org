# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  include SemanticLogger::Loggable
  include Roadie::Rails::Automatic

  default from: Gemcutter::MAIL_SENDER
  default_url_options[:host] = Gemcutter::HOST
  default_url_options[:protocol] = Gemcutter::PROTOCOL
  # Emails have no request locale; always generate unprefixed (default-locale) URLs.
  default_url_options[:locale] = nil

  layout "mailer"

  after_deliver :record_delivery

  def record_delivery
    message.to_addrs&.each do |address|
      next unless (user = User.find_by_email(address))

      user.record_event!(Events::UserEvent::EMAIL_SENT,
        to: address,
        from: message.from_addrs&.first,
        subject: message.subject,
        message_id: message.message_id,
        action: action_name,
        mailer: mailer_name)
    end
  end

  private

  # Render an email (subject AND body) in the recipient's saved locale. The whole
  # mail(...) call must be wrapped because the subject's I18n.t is evaluated
  # eagerly as an argument. Falls back to the default locale when the recipient
  # has no preference. NOTE: links stay default-locale for now (mailer URLs are
  # generated with locale: nil); localizing them is a follow-up.
  def with_locale_for(user, &)
    I18n.with_locale((user&.locale).presence || I18n.default_locale, &)
  end
end

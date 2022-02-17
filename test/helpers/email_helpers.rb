module EmailHelpers
  def last_email_link
    Delayed::Worker.new.work_off
    confirmation_link
  end

  def confirmation_link_from(job)
    Delayed::Worker.new.run(job)
    confirmation_link
  end

  def last_email
    ActionMailer::Base.deliveries.last
  end

  def mails_count
    ActionMailer::Base.deliveries.size
  end

  def confirmation_link
    body = last_email.parts[1].body.decoded.to_s
    link = %r{http://localhost/email_confirmations([^";]*)}.match(body)
    link[0]
  end

  def otp_code_from(job)
    Delayed::Worker.new.run(job)
    otp_code
  end

  def otp_code
    %r{Your OTP code is (\d{6})}.match(last_email.subject)[1]
  end
end

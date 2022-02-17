class OtpMailer < ApplicationMailer
  include Roadie::Rails::Automatic

  default_url_options[:host] = Gemcutter::HOST
  default_url_options[:protocol] = Gemcutter::PROTOCOL

  default from: Clearance.configuration.mailer_sender

  def auth_code(user, code)
    @user = User.find(user)
    @auth_code = code
    mail to: @user.email, subject: "Your OTP code is #{@auth_code}"
  end
end
class UserMailer < ActionMailer::Base
  default from: "registrations@edu-apps.org"

  def email_confirmation(registration_code, confirmation_route_url)
    @user = registration_code.user
    @code = registration_code
    @return_url = "#{confirmation_route_url}?code=#{@code.code}"
    mail(to: "#{@user.name} <#{registration_code.email}>", subject: "Please confirm your email address")
  end
end

EduApps::Application.configure do
  # email configuration
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_options = {from: 'no-replyy@dev-edu-apps.org'}

  # set delivery method to :smtp, :sendmail or :test
  config.action_mailer.delivery_method = ENV["EMAIL_DELIVERY_METHOD"]

  if(ENV["EMAIL_DELIVERY_METHOD"] == 'smtp')
    config.action_mailer.smtp_settings = {
        :address        => ENV["EMAIL_SMTP_ADDRESS"],
        :port           => ENV["EMAIL_SMTP_PORT"],
        :domain         => ENV["EMAIL_SMTP_DOMAIN"],
        :authentication => ENV['EMAIL_SMTP_AUTHENTICATION'],
        :user_name      => ENV['EMAIL_SMTP_USER_NAME'],
        :password       => ENV['EMAIL_SMTP_PASSWORD']
    }.delete_if{|k,v| v.nil?}
  end
end

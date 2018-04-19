# frozen_string_literal: true

# Defines the Application Mailer settings
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
end

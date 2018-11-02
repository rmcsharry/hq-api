# frozen_string_literal: true

# Overrides Devise mailer actions
class DeviseMailer < Devise::Mailer
  include Devise::Mailers::Helpers

  # Deliver an invitation email
  def invitation_instructions(record, token, opts = {})
    @set_password_url = "#{opts[:set_password_url]}?invitation_token=#{token}"
    devise_mail(record, :invitation_instructions, opts)
  end

  def reset_password_instructions(record, token, opts = {})
    @reset_password_url = "#{opts[:reset_password_url]}?reset_password_token=#{token}"
    devise_mail(record, :reset_password_instructions, opts)
  end

  def confirmation_instructions(record, token, opts = {})
    @confirm_email_url = "#{opts[:confirmation_url]}?confirmation_token=#{token}"
    devise_mail(record, :confirmation_instructions, opts)
  end

  def email_changed(record, opts={})
    @new_email = opts[:new_email]
    devise_mail(record, :email_changed, opts)
  end
end

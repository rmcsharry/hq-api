# frozen_string_literal: true

# Defines the decorator for Newsletter Subscribers
class NewsletterSubscriberDecorator < ApplicationDecorator
  delegate_all

  # Returns the Newsletter Subscriber's full name
  # @return [String]
  def name
    "#{first_name} #{last_name}".strip
  end

  # Returns the Newsletter Subscriber's full name is list style
  # @return [String]
  def name_list
    "#{last_name}, #{first_name}"
  end

  # Returns formal salutation for the Newsletter Subscriber including
  # their last name, gender, professional title and nobility title
  # @return [String]
  def formal_salutation
    return 'Sehr geehrte Damen und Herren' if last_name.blank?

    salutation_prefix = gender == :female ? 'geehrte' : 'geehrter'
    salutation = ['Sehr', salutation_prefix, gender_text, professional_title_text, nobility_title_text, last_name]
    salutation.compact.join(' ')
  end
end

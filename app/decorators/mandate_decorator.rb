# frozen_string_literal: true

# Defines the decorator for mandates
class MandateDecorator < Draper::Decorator
  delegate_all

  def humanize_confidential
    'Persönlich / Vertraulich' if confidential
  end

  # Returns the name of the Mandate owner(s)
  # @return [String]
  def owner_name
    owners.map { |member| member.contact.decorate.name_list }.to_sentence(locale: :de)
  end
end

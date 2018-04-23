# frozen_string_literal: true

# Defines the decorator for mandates
class MandateDecorator < Draper::Decorator
  delegate_all

  # Returns the name of the Mandate owner(s)
  # @return [String]
  def owner_name
    owners.map { |member| member.contact.decorate.name }.to_sentence(locale: :de)
  end
end

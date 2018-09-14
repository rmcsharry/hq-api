# frozen_string_literal: true

# Defines the decorator for mandates
class MandateDecorator < Draper::Decorator
  delegate_all

  # Returns the name of the Mandate owner(s)
  # @return [String]
  def owner_name
    owners.preload(:contact).map { |member| member.contact.decorate.name_list }.to_sentence(locale: :de)
  end
end

# frozen_string_literal: true

# Defines the decorator for mandates
class MandateDecorator < ApplicationDecorator
  delegate_all

  def humanize_confidential
    'Persönlich / Vertraulich' if confidential
  end

  # Returns the name of the Mandate owner(s)
  # @return [String]
  def owner_name
    owners
      .map { |member| member.contact.decorate.name_list }
      .sort
      .to_sentence(locale: :de)
  end

  def data_integrity_partial_score
    format_percentage(object.data_integrity_partial_score * 100, 0)
  end

  def data_integrity_score
    format_percentage(object.data_integrity_score * 100, 0)
  end
end

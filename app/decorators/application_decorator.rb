# frozen_string_literal: true

# Defines the root application decorator
class ApplicationDecorator < Draper::Decorator
  def helpers
    @helpers ||= ActionController::Base.helpers
  end

  def format_currency(value, unit = '')
    helpers.number_to_currency(value, unit: unit)
  end

  def format_percentage(value)
    helpers.number_to_percentage(value, precision: 2, format: '%n')
  end
end

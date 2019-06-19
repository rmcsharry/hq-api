# frozen_string_literal: true

# Defines the root application decorator
class ApplicationDecorator < Draper::Decorator
  def helpers
    @helpers ||= ActionController::Base.helpers
  end

  def format_currency(value, currency = 'EUR')
    money = Money.from_amount(value, currency)
    money.format(symbol: money.currency.to_s + ' ')
  end

  def format_percentage(value, precision = 2)
    helpers.number_to_percentage(value, precision: precision, format: '%n')
  end
end

# frozen_string_literal: true

# Defines the root application decorator
class ApplicationDecorator < Draper::Decorator
  def helpers
    @helpers ||= ActionController::Base.helpers
  end

  def format_currency(value:, currency: 'EUR', no_cents: false)
    money = Money.from_amount(value, currency)
    money.format(symbol: '', no_cents: no_cents)
  end

  def format_percentage(value, precision = 2)
    helpers.number_to_percentage(value, precision: precision, format: '%n')
  end

  def format_decimal(value, precision = 2)
    helpers.number_with_precision(value, precision: precision)
  end
end

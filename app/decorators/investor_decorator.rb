# frozen_string_literal: true

# Defines the decorator for investors
class InvestorDecorator < ApplicationDecorator
  delegate_all

  # Returns a formatted version of the investors
  # total investment amount
  # @return [String]
  def amount_total
    format_currency object.amount_total, object.fund.currency
  end
end

# frozen_string_literal: true

# Defines the decorator for fund_cashflows
class FundCashflowDecorator < ApplicationDecorator
  delegate_all

  # Returns a formatted version of the fund_cashflows
  # valuta_date
  # @return [String]
  def valuta_date
    object.valuta_date.strftime('%d.%m.%Y')
  end
end

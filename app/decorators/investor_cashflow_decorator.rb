# frozen_string_literal: true

# Defines the decorator for investor_cashflows
class InvestorCashflowDecorator < ApplicationDecorator
  delegate_all

  def capital_call_management_fees_amount
    format_currency(object.capital_call_management_fees_amount)
  end

  def capital_call_management_fees_percentage
    format_percentage(percentage_of_capital_call_amount(object.capital_call_management_fees_amount))
  end

  def capital_call_compensatory_interest_amount
    format_currency(object.capital_call_compensatory_interest_amount)
  end

  def capital_call_compensatory_interest_percentage
    format_percentage(percentage_of_capital_call_amount(object.capital_call_compensatory_interest_amount))
  end

  def capital_call_gross_amount
    format_currency(object.capital_call_gross_amount)
  end

  def capital_call_gross_percentage
    format_percentage(percentage_of_capital_call_amount(object.capital_call_gross_amount))
  end

  def capital_call_total_amount
    format_currency(object.capital_call_total_amount)
  end

  def capital_call_total_percentage
    format_percentage(percentage_of_capital_call_amount(object.capital_call_total_amount))
  end

  def distribution_compensatory_interest_amount
    format_currency(object.distribution_compensatory_interest_amount)
  end

  def distribution_compensatory_interest_percentage
    format_percentage(percentage_of_distribution_amount(object.distribution_compensatory_interest_amount))
  end

  def distribution_dividends_amount
    format_currency(object.distribution_dividends_amount)
  end

  def distribution_dividends_percentage
    format_percentage(percentage_of_distribution_amount(object.distribution_dividends_amount))
  end

  def distribution_interest_amount
    format_currency(object.distribution_interest_amount)
  end

  def distribution_interest_percentage
    format_percentage(percentage_of_distribution_amount(object.distribution_interest_amount))
  end

  def distribution_misc_profits_amount
    format_currency(object.distribution_misc_profits_amount)
  end

  def distribution_misc_profits_percentage
    format_percentage(percentage_of_distribution_amount(object.distribution_misc_profits_amount))
  end

  def distribution_participation_profits_amount
    format_currency(object.distribution_participation_profits_amount)
  end

  def distribution_participation_profits_percentage
    format_percentage(percentage_of_distribution_amount(object.distribution_participation_profits_amount))
  end

  def distribution_recallable_amount
    format_currency(object.distribution_recallable_amount)
  end

  def distribution_recallable_percentage
    format_percentage(percentage_of_distribution_amount(object.distribution_recallable_amount))
  end

  def distribution_repatriation_amount
    format_currency(object.distribution_repatriation_amount)
  end

  def distribution_repatriation_percentage
    format_percentage(percentage_of_distribution_amount(object.distribution_repatriation_amount))
  end

  def distribution_structure_costs_amount
    format_currency(object.distribution_structure_costs_amount)
  end

  def distribution_structure_costs_percentage
    format_percentage(percentage_of_distribution_amount(object.distribution_structure_costs_amount))
  end

  def distribution_total_amount
    format_currency(object.distribution_total_amount)
  end

  def distribution_total_percentage
    format_percentage(percentage_of_distribution_amount(object.distribution_total_amount))
  end

  def distribution_withholding_tax_amount
    format_currency(object.distribution_withholding_tax_amount)
  end

  def distribution_withholding_tax_percentage
    format_percentage(percentage_of_distribution_amount(object.distribution_withholding_tax_amount))
  end

  private

  def percentage_of_distribution_amount(value)
    value / object.distribution_total_amount * 100
  end

  def percentage_of_capital_call_amount(value)
    value / object.capital_call_total_amount * 100
  end

  def currency
    fund_cashflow.fund.currency
  end
end

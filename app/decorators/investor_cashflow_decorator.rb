# frozen_string_literal: true

# Defines the decorator for investor_cashflows
# rubocop:disable Metrics/ClassLength
class InvestorCashflowDecorator < ApplicationDecorator
  delegate_all

  def capital_call_management_fees_amount
    format_absolute_amount(object.capital_call_management_fees_amount)
  end

  def capital_call_management_fees_percentage
    format_percentage(percentage_of_total_investment(object.capital_call_management_fees_amount))
  end

  def capital_call_compensatory_interest_amount
    format_absolute_amount(object.capital_call_compensatory_interest_amount)
  end

  def capital_call_compensatory_interest_percentage
    format_percentage(percentage_of_total_investment(object.capital_call_compensatory_interest_amount))
  end

  def capital_call_gross_amount
    format_absolute_amount(object.capital_call_gross_amount)
  end

  def capital_call_gross_percentage
    format_percentage(percentage_of_total_investment(object.capital_call_gross_amount))
  end

  def capital_call_total_amount
    format_absolute_amount(object.capital_call_total_amount)
  end

  def capital_call_total_percentage
    format_percentage(percentage_of_total_investment(object.capital_call_total_amount))
  end

  def distribution_compensatory_interest_amount
    format_absolute_amount(object.distribution_compensatory_interest_amount)
  end

  def distribution_compensatory_interest_percentage
    format_percentage(percentage_of_total_investment(object.distribution_compensatory_interest_amount))
  end

  def distribution_dividends_amount
    format_absolute_amount(object.distribution_dividends_amount)
  end

  def distribution_dividends_percentage
    format_percentage(percentage_of_total_investment(object.distribution_dividends_amount))
  end

  def distribution_interest_amount
    format_absolute_amount(object.distribution_interest_amount)
  end

  def distribution_interest_percentage
    format_percentage(percentage_of_total_investment(object.distribution_interest_amount))
  end

  def distribution_misc_profits_amount
    format_absolute_amount(object.distribution_misc_profits_amount)
  end

  def distribution_misc_profits_percentage
    format_percentage(percentage_of_total_investment(object.distribution_misc_profits_amount))
  end

  def distribution_participation_profits_amount
    format_absolute_amount(object.distribution_participation_profits_amount)
  end

  def distribution_participation_profits_percentage
    format_percentage(percentage_of_total_investment(object.distribution_participation_profits_amount))
  end

  def distribution_recallable_amount
    format_absolute_amount(object.distribution_recallable_amount)
  end

  def distribution_recallable_percentage
    format_percentage(percentage_of_total_investment(object.distribution_recallable_amount))
  end

  def distribution_repatriation_amount
    format_absolute_amount(object.distribution_repatriation_amount)
  end

  def distribution_repatriation_percentage
    format_percentage(percentage_of_total_investment(object.distribution_repatriation_amount))
  end

  def distribution_structure_costs_amount
    format_absolute_amount(object.distribution_structure_costs_amount)
  end

  def distribution_structure_costs_percentage
    format_percentage(percentage_of_total_investment(object.distribution_structure_costs_amount))
  end

  def distribution_total_amount
    format_absolute_amount(object.distribution_total_amount)
  end

  def distribution_total_percentage
    format_percentage(percentage_of_total_investment(object.distribution_total_amount))
  end

  def distribution_withholding_tax_amount
    format_absolute_amount(object.distribution_withholding_tax_amount)
  end

  def distribution_withholding_tax_percentage
    format_percentage(percentage_of_total_investment(object.distribution_withholding_tax_amount))
  end

  def investor_called_amount
    format_absolute_amount(object.investor_called_amount)
  end

  def investor_called_percentage
    format_percentage(object.investor_called_percentage)
  end

  def investor_open_amount
    format_absolute_amount(object.investor_open_amount)
  end

  def investor_open_percentage
    format_percentage(object.investor_open_percentage)
  end

  def net_cashflow_amount
    format_absolute_amount(object.net_cashflow_amount)
  end

  def net_cashflow_percentage
    format_percentage(percentage_of_total_investment(object.net_cashflow_amount))
  end

  private

  def format_absolute_amount(amount)
    return nil if amount.zero?

    format_currency(amount.abs, fund_cashflow.fund.currency)
  end

  def format_percentage(value)
    super(value, 1)
  end

  def percentage_of_total_investment(value)
    return nil if value.zero?

    rounded_percentage = (value.abs / object.investor.amount_total * 100).round(1)
    return 'N/A' if rounded_percentage.zero?

    rounded_percentage
  end
end
# rubocop:enable Metrics/ClassLength

# frozen_string_literal: true

# Defines the decorator for fund reports
class FundReportDecorator < ApplicationDecorator
  delegate_all

  def dpi
    format_decimal(object.dpi)
  end

  def irr
    format_percentage(object.irr)
  end

  def rvpi
    format_decimal(object.rvpi)
  end

  def tvpi
    format_decimal(object.tvpi)
  end

  private

  def format_percentage(value)
    return 'N/A' if value.nil?

    super(value * 100, 1)
  end

  def format_decimal(value)
    return 'N/A' if value.nil?

    super(value, 1)
  end
end

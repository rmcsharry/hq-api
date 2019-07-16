# frozen_string_literal: true

# Defines the decorator for fund reports
class FundReportDecorator < ApplicationDecorator
  delegate_all

  def dpi
    format_percentage(object.dpi)
  end

  def irr
    format_percentage(object.irr)
  end

  def rvpi
    format_percentage(object.rvpi)
  end

  def tvpi
    format_percentage(object.tvpi)
  end

  private

  def format_percentage(value)
    super(value * 100, 1)
  end
end

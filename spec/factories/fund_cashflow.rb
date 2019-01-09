# frozen_string_literal: true

FactoryBot.define do
  factory :fund_cashflow do
    fund { build(:fund) }
    valuta_date { 1.day.ago }
  end
end

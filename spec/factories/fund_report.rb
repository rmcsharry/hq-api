# frozen_string_literal: true

FactoryBot.define do
  factory :fund_report, class: FundReport do
    description { 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.' }
    fund { build(:fund) }
    irr { 0.065 }
    valuta_date { 1.day.ago }
  end
end

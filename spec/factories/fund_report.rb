# frozen_string_literal: true

FactoryBot.define do
  factory :fund_report do
    description { 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.' }
    fund { build(:fund) }
    irr { 0.065 }
    tvpi { 0.02 }
    dpi { 0.03 }
    rvpi { 0.04 }
    valuta_date { 1.day.ago }
  end
end

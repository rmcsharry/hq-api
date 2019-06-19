# frozen_string_literal: true

FactoryBot.define do
  factory :fund_cashflow do
    description_bottom { Faker::Lorem.sentence }
    description_top { Faker::Lorem.sentence }
    fund { build(:fund) }
    valuta_date { 1.day.ago }
  end
end

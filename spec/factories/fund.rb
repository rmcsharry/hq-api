# frozen_string_literal: true

FactoryBot.define do
  factory :fund, class: Fund::PrivateEquity do
    type 'Fund::PrivateEquity'
    currency 'EUR'
    duration 10
    issuing_year 2010
    name 'HQT Merkur Multi IV GmbH & Co. KG'
    strategy :buyout

    factory :fund_private_debt, class: Fund::PrivateDebt do
      strategy :senior
    end

    factory :fund_private_equity, class: Fund::PrivateEquity do
      strategy :buyout
    end

    factory :fund_real_estate, class: Fund::RealEstate do
      strategy :core_plus
    end
  end
end

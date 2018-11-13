# frozen_string_literal: true

FactoryBot.define do
  factory :fund do
    asset_class :private_equity
    currency 'EUR'
    duration 10
    issuing_year 2010
    name 'HQT Merkur Multi IV GmbH & Co. KG'
    strategy :buyout
  end
end

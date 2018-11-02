# frozen_string_literal: true

FactoryBot.define do
  factory :address do
    owner { build(:contact_person) }
    postal_code { Faker::Address.zip_code }
    city { Faker::Address.city }
    country { Faker::Address.country_code }
    addition { Faker::Address.secondary_address }
    category :home
    street_and_number { Faker::Address.street_address }

    trait :for_fund do
      owner { build(:fund) }
    end
  end
end

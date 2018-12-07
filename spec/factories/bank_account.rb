# frozen_string_literal: true

FactoryBot.define do
  factory :bank_account do
    account_type { 'currency_account' }
    bic { Faker::Bank.swift_bic }
    currency { 'EUR' }
    iban { 'DE21301204000000015228' }
    owner { build(:mandate) }
    owner_name { Faker::Name.name }

    association :bank, factory: :contact_organization, strategy: :build

    trait :for_fund do
      owner { build(:fund) }
    end
  end
end

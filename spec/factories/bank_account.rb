# frozen_string_literal: true

FactoryBot.define do
  factory :bank_account do
    account_type 'currency_account'
    owner { Faker::Name.name }
    currency 'EUR'
    iban 'DE21301204000000015228'
    bic { Faker::Bank.swift_bic }

    association :mandate, factory: :mandate, strategy: :build
    association :bank, factory: :contact_organization, strategy: :build
  end
end

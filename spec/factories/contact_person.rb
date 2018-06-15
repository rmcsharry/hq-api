# frozen_string_literal: true

FactoryBot.define do
  factory :contact_person, class: Contact::Person do
    transient do
      street_and_number '875 South Bundy Drive'
      phone '+49301234567'
    end

    first_name 'Thomas'
    last_name  'Guntersen'
    gender     :male

    trait :with_contact_details do
      legal_address { create(:address, street_and_number: street_and_number, contact: @instance) }
      primary_contact_address { create(:address, street_and_number: street_and_number, contact: @instance) }
      primary_phone { create(:phone, primary: true, value: phone, contact: @instance) }
      primary_email { create(:email, primary: true, contact: @instance) }
    end
  end
end

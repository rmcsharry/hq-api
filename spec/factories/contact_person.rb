# frozen_string_literal: true

FactoryBot.define do
  factory :contact_person, class: Contact::Person do
    transient do
      street_and_number { '875 South Bundy Drive' }
      phone { '+49301234567' }
      mandate { build(:mandate) }
    end

    first_name { 'Thomas' }
    last_name  { 'Guntersen' }
    gender     { :male }

    trait :with_mandate do
      mandate_members { [create(:mandate_member, contact: @instance, mandate: mandate)] }
    end

    trait :with_contact_details do
      legal_address { create(:address, street_and_number: street_and_number, owner: @instance) }
      primary_contact_address { create(:address, street_and_number: street_and_number, owner: @instance) }
      primary_phone { create(:phone, primary: true, value: phone, contact: @instance) }
      primary_email { create(:email, primary: true, contact: @instance) }
    end
  end
end

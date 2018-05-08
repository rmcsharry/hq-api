# frozen_string_literal: true

FactoryBot.define do
  factory :contact_person, class: Contact::Person do
    first_name 'Thomas'
    last_name  'Guntersen'
    gender     :male

    trait :with_contact_details do
      legal_address { create(:address, contact: @instance) }
      primary_contact_address { create(:address, contact: @instance) }
      primary_phone { create(:phone, primary: true, contact: @instance) }
      primary_email { create(:email, primary: true, contact: @instance) }
    end
  end
end

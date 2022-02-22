# frozen_string_literal: true

FactoryBot.define do
  factory :contact_person, class: Contact::Person do
    # score uses a restricted range (ie. NOT 0 to 100%) so we can test filtering on min/max
    data_integrity_score { rand(0.2..0.8) }

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

    trait :with_scoreable_data do
      nationality { 'DE' }
      date_of_birth { 50.years.ago }
    end
  end
end

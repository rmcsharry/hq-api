# frozen_string_literal: true

FactoryBot.define do
  factory :contact_organization, class: Contact::Organization do
    # score uses a restricted range (ie. NOT 0 to 100%) so we can test filtering on min/max
    data_integrity_score { rand(0.2..0.8) }

    transient do
      street_and_number { '875 South Bundy Drive' }
      phone { '+49301234567' }
      mandate { build(:mandate) }
    end

    organization_name { 'ACME GmbH' }
    organization_type { :gmbh }

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
      commercial_register_number { Faker::Company.duns_number }
      commercial_register_office { Faker::Address.city }
      organization_category { Faker::Company.type }
      organization_industry { Faker::Company.industry }
    end

    trait :with_scoreable_relationships do
      passive_contact_relationships do
        [
          create(
            :contact_relationship,
            role: 'shareholder',
            source_contact: build(:contact_person),
            target_contact: @instance
          ),
          create(
            :contact_relationship,
            role: 'beneficial_owner',
            source_contact: build(:contact_person),
            target_contact: @instance
          )
        ]
      end
    end
  end
end

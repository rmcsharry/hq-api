# frozen_string_literal: true

FactoryBot.define do
  factory :mandate do
    # score uses a restricted range (ie. NOT 0 to 100%) so we can test filtering on min/max
    data_integrity_score { rand(0.2..0.8) }

    transient do
      owner { build(:contact_person) }
      owner_contact_address { build(:address, owner: owner) }
      owner_legal_address { build(:address, owner: owner) }
    end

    category { :family_office_with_investment_advice }

    mandate_groups_organizations { [build(:mandate_group, group_type: 'organization')] }
    mandate_members do
      [
        create(:mandate_member, mandate: @instance, member_type: :primary_consultant),
        create(:mandate_member, mandate: @instance, member_type: :secondary_consultant)
      ]
    end

    trait :with_owner do
      mandate_members { [create(:mandate_member, contact: owner, mandate: @instance)] }
      primary_owner { owner }
      contact_address { owner_contact_address }
      legal_address { owner_legal_address }
    end

    trait :with_multiple_owners do
      mandate_members do
        [
          create(:mandate_member, contact: owner, mandate: @instance),
          create(:mandate_member, mandate: @instance)
        ]
      end
      primary_owner { owner }
      contact_address { owner_contact_address }
      legal_address { owner_legal_address }
    end

    trait :with_bank_account do
      bank_accounts do
        [
          create(:bank_account, owner: @instance, iban: 'DE12500105170648489890')
        ]
      end
    end

    trait :with_scoreable_data do
      datev_creditor_id { Faker::Number.number(10) }
      datev_debitor_id { Faker::Number.number(10) }
      mandate_number { "#{Faker::Number.number(3)}-#{Faker::Number.number(3)}-#{Faker::Number.number(3)}" }
      psplus_id { Faker::Number.number(9) }
      valid_from { Faker::Date.between(15.years.ago, Time.zone.today) }
      mandate_members do
        [
          create(:mandate_member, mandate: @instance, member_type: :primary_consultant),
          create(:mandate_member, mandate: @instance, member_type: :secondary_consultant),
          create(:mandate_member, mandate: @instance, member_type: :assistant),
          create(:mandate_member, mandate: @instance, member_type: :bookkeeper)
        ]
      end
    end
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :mandate do
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
  end
end

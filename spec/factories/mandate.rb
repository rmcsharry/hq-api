# frozen_string_literal: true

FactoryBot.define do
  factory :mandate do
    category :family_office_with_investment_advice
    primary_consultant { build(:contact_person) }
    secondary_consultant { build(:contact_person) }

    mandate_groups_organizations { [build(:mandate_group, group_type: 'organization')] }

    trait :with_multiple_owners do
      mandate_members do
        [
          create(:mandate_member, mandate: @instance),
          create(:mandate_member, mandate: @instance)
        ]
      end
    end
  end
end

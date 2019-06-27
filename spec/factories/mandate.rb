# frozen_string_literal: true

FactoryBot.define do
  factory :mandate do
    data_integrity_score { 0.5 }
    data_integrity_partial_score { 0.5 }
    data_integrity_missing_fields { [] }

    transient do
      owner { build(:contact_person) }
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
    end

    trait :with_multiple_owners do
      mandate_members do
        [
          create(:mandate_member, contact: owner, mandate: @instance),
          create(:mandate_member, mandate: @instance)
        ]
      end
    end
  end
end

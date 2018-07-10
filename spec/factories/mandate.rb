# frozen_string_literal: true

FactoryBot.define do
  factory :mandate do
    category :family_office_with_investment_advice
    primary_consultant { build(:contact_person) }
    secondary_consultant { build(:contact_person) }

    mandate_groups_organizations { [build(:mandate_group, group_type: 'organization')] }
  end
end

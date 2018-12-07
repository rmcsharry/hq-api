# frozen_string_literal: true

FactoryBot.define do
  factory :organization_member do
    role { 'Gesellschafter' }
    contact { build(:contact_person) }
    organization { build(:contact_organization) }
  end
end

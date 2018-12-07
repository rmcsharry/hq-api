# frozen_string_literal: true

FactoryBot.define do
  factory :mandate_member do
    member_type { :owner }
    contact { build(:contact_person) }
    mandate { build(:mandate) }
  end
end

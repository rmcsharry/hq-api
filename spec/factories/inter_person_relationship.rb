# frozen_string_literal: true

FactoryBot.define do
  factory :inter_person_relationship do
    role :uncle
    source_person { build(:contact_person) }
    target_person { build(:contact_person) }
  end
end

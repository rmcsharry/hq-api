# frozen_string_literal: true

FactoryBot.define do
  factory :contact_relationship do
    role { :aunt_uncle }
    source_contact { build(:contact_person) }
    target_contact { build(:contact_person) }

    factory :person_person_relationship do
      role { :aunt_uncle }
      source_contact { build(:contact_person) }
      target_contact { build(:contact_person) }
    end

    factory :person_organization_relationship do
      role { :ceo }
      source_contact { build(:contact_person) }
      target_contact { build(:contact_organization) }
    end

    # TODO: Does this even make sense to put it this way?
    # We should build it like `aunt_uncle` -> `ceo_employer` or something
    # factory :organization_person_relationship do
    #   role { :ceo }
    #   source_contact { build(:contact_person) }
    #   target_contact { build(:contact_organization) }
    # end

    factory :organization_organization_relationship do
      role { :bookkeeper }
      source_contact { build(:contact_organization) }
      target_contact { build(:contact_organization) }
    end
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :contact_organization, class: Contact::Organization do
    organization_name 'ACME GmbH'
    organization_type :gmbh
  end
end

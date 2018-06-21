# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    transient do
      first_name 'John'
      last_name 'Doe'
      permitted_mandates []
      roles []
    end

    sequence(:email) { |n| "demo#{n}@hqfinanz.de" }
    password 'testmctest1A!'
    confirmed_at { 1.day.ago }
    contact { build(:contact_person, first_name: first_name, last_name: last_name) }

    after(:create) do |user, evaluator|
      unless evaluator.roles.empty?
        mandate_group = create(:mandate_group, mandates: evaluator.permitted_mandates)
        create(:user_group, users: [user], mandate_groups: [mandate_group], roles: evaluator.roles)
      end
    end
  end
end

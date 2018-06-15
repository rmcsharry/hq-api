# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    transient do
      first_name 'John'
      last_name 'Doe'
    end

    sequence(:email) { |n| "demo#{n}@hqfinanz.de" }
    password 'testmctest1A!'
    confirmed_at { 1.day.ago }
    contact { build(:contact_person, first_name: first_name, last_name: last_name) }
  end
end

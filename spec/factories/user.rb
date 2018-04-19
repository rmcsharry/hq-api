# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "demo#{n}@hqfinanz.de" }
    password 'testmctest1A!'
    confirmed_at { 1.day.ago }
  end
end

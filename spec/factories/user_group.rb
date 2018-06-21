# frozen_string_literal: true

FactoryBot.define do
  factory :user_group do
    name { Faker::RickAndMorty.location }
    comment { Faker::RickAndMorty.quote }
    roles { %w[admin mandates_read mandates_write] }
  end
end

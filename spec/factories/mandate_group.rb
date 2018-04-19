# frozen_string_literal: true

FactoryBot.define do
  factory :mandate_group do
    name { Faker::HitchhikersGuideToTheGalaxy.location }
    group_type 'organization'
  end
end

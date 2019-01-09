# frozen_string_literal: true

FactoryBot.define do
  factory :user_group do
    name { Faker::TvShows::RickAndMorty.quote }
    comment { Faker::TvShows::RickAndMorty.quote }
    roles { %w[admin mandates_read mandates_write] }
  end
end

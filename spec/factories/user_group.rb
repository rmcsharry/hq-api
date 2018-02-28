FactoryBot.define do
  factory :user_group do
    name { Faker::RickAndMorty.location }
    comment { Faker::RickAndMorty.quote }
  end
end

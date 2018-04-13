FactoryBot.define do
  factory :address do
    contact { build(:contact_person) }
    postal_code { Faker::Address.zip_code }
    city { Faker::Address.city }
    country { Faker::Address.country_code }
    addition { Faker::Address.secondary_address }
    category :home
    street_and_number { Faker::Address.street_address }
  end
end

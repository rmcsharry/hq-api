FactoryBot.define do
  factory :activity do
    started_at { 1.day.ago }
    title 'Call with Mr. X'
    description 'Lorem ipsum'
    creator { create(:user) }
  end
end

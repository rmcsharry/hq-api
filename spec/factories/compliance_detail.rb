# frozen_string_literal: true

FactoryBot.define do
  factory :compliance_detail do
    contact { build(:contact_person) }
    wphg_classification :born_professional
    kagb_classification :semi_professional
    occupation_role :managing_director
    occupation_title { Faker::Job.title }
    retirement_age 64
  end
end

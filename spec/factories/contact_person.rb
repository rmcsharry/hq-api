FactoryBot.define do
  factory :contact_person, class: Contact::Person do
    first_name 'Thomas'
    last_name  'Guntersen'
    gender     :male
  end
end

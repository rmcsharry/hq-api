FactoryBot.define do
  factory :contact_detail do
    contact { build(:contact_person) }
    primary false
    category :work

    trait :primary do
      primary true
    end

    factory :phone, class: ContactDetail::Phone do
      value '+49301234567'
    end

    factory :fax, class: ContactDetail::Fax do
      value '+49307654321'
    end

    factory :email, class: ContactDetail::Email do
      value 'peter@novo.de'
    end

    factory :website, class: ContactDetail::Website do
      value 'https://www.hqfinanz.de'
    end
  end
end

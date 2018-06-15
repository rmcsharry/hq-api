# frozen_string_literal: true

FactoryBot.define do
  factory :tax_detail do
    de_tax_number '21/815/08150'
    de_tax_id '12345678911'
    de_tax_office 'Finanzamt Berlin-Charlottenburg'
    contact { build(:contact_person, tax_detail: @instance.presence) }

    trait :organization do
      eu_vat_number 'DE314892157'
    end
  end
end

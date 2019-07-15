# frozen_string_literal: true

FactoryBot.define do
  factory :tax_detail do
    de_tax_id { '12345678911' }
    de_tax_number { '21/815/08150' }
    de_tax_office { 'Finanzamt Berlin-Charlottenburg' }
    contact { build(:contact_person, tax_detail: @instance.presence) }

    trait :organization do
      eu_vat_number { 'DE314892157' }
    end

    trait :with_scoreable_person_data do
      de_church_tax { true }
      de_health_insurance { true }
      de_retirement_insurance { true }
      de_unemployment_insurance { true }
      us_fatca_status { TaxDetail::US_FATCA_STATUSES.sample }
      us_tax_form { TaxDetail::US_TAX_FORMS.sample }
      us_tax_number { Faker::Number.number(10) }
    end

    trait :with_scoreable_organization_data do
      us_fatca_status { TaxDetail::US_FATCA_STATUSES.sample }
      us_tax_form { TaxDetail::US_TAX_FORMS.sample }
      us_tax_number { Faker::Number.number(10) }
      legal_entity_identifier { Faker::Company.ein }
      transparency_register { true }
    end
  end
end

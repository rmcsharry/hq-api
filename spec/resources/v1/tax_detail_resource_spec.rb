RSpec.describe V1::TaxDetailResource, type: :resource do
  let(:tax_detail) { build(:tax_detail) }
  subject { described_class.new(tax_detail, {}) }

  it { is_expected.to have_attribute :de_tax_number }
  it { is_expected.to have_attribute :de_tax_id }
  it { is_expected.to have_attribute :de_tax_office }
  it { is_expected.to have_attribute :de_retirement_insurance }
  it { is_expected.to have_attribute :de_unemployment_insurance }
  it { is_expected.to have_attribute :de_health_insurance }
  it { is_expected.to have_attribute :de_church_tax }
  it { is_expected.to have_attribute :us_tax_number }
  it { is_expected.to have_attribute :us_tax_form }
  it { is_expected.to have_attribute :us_fatca_status }
  it { is_expected.to have_attribute :common_reporting_standard }
  it { is_expected.to have_attribute :eu_vat_number }
  it { is_expected.to have_attribute :legal_entity_identifier }
  it { is_expected.to have_attribute :transparency_register }

  it { is_expected.to have_many(:foreign_tax_numbers) }
  it { is_expected.to have_one(:contact) }
end

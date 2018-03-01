# == Schema Information
#
# Table name: tax_details
#
#  id                        :uuid             not null, primary key
#  de_tax_number             :string
#  de_tax_id                 :string
#  de_tax_office             :string
#  de_retirement_insurance   :boolean          default(FALSE), not null
#  de_unemployment_insurance :boolean          default(FALSE), not null
#  de_health_insurance       :boolean          default(FALSE), not null
#  de_church_tax             :boolean          default(FALSE), not null
#  us_tax_number             :string
#  us_tax_form               :string
#  us_fatca_status           :string
#  common_reporting_standard :boolean          default(FALSE), not null
#  eu_vat_number             :string
#  legal_entity_identifier   :string
#  transparency_register     :boolean          default(FALSE), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  contact_id                :uuid
#
# Indexes
#
#  index_tax_details_on_contact_id  (contact_id)
#
# Foreign Keys
#
#  fk_rails_...  (contact_id => contacts.id)
#

require 'rails_helper'

RSpec.describe TaxDetail, type: :model do
  subject { build(:tax_detail, contact: contact) }
  let(:contact) { build(:contact_person) }

  it { is_expected.to have_many(:foreign_tax_numbers) }
  it { is_expected.to enumerize(:us_tax_form) }
  it { is_expected.to enumerize(:us_fatca_status) }

  describe '#contact' do
    it { is_expected.to belong_to(:contact).required }
    it { is_expected.to validate_uniqueness_of(:contact_id).case_insensitive }
  end

  describe '#de_tax_number' do
    let(:valid_tax_numbers) do
      ['93815/08152', '2893081508152', '181/815/08155', '9181081508155', '21/815/08150', '1121081508150']
    end
    let(:invalid_tax_numbers) { %w[ABC 123456789 0] }

    it 'validates tax number format' do
      expect(subject).to allow_values(*valid_tax_numbers).for(:de_tax_number)
      expect(subject).not_to allow_values(*invalid_tax_numbers).for(:de_tax_number)
    end
  end

  describe '#de_tax_id' do
    let(:valid_tax_ids) { %w[12345678995 12345679998] }
    # TODO: 12345678996 and 12345679998 should be invalid as well but checksum is currently not checked
    let(:invalid_tax_ids) { %w[ABC 02345679999 0] }

    it 'validates id format' do
      expect(subject).to allow_values(*valid_tax_ids).for(:de_tax_id)
      expect(subject).not_to allow_values(*invalid_tax_ids).for(:de_tax_id)
    end
  end

  describe '#eu_vat_number' do
    context 'contact is person' do
      let(:contact) { build(:contact_person) }

      it 'does validate absence' do
        expect(subject).to validate_absence_of(:eu_vat_number)
      end
    end

    context 'contact is organization' do
      let(:contact) { build(:contact_organization) }
      let(:valid_vat_numbers) { %w[DE314892157 ATU99999999 CY99999999L DE999999999 FI99999999 NL999999999B99] }
      let(:invalid_vat_number) { %w[ABC DE00000000 DE31489215 D3314892157 XX314892157 1234567890] }

      it 'validates vat format' do
        expect(subject).to allow_values(*valid_vat_numbers).for(:eu_vat_number)
        expect(subject).not_to allow_values(*invalid_vat_number).for(:eu_vat_number)
      end
    end
  end

  describe 'insurances and church tax' do
    context 'contact is organization' do
      let(:contact) { build(:contact_organization) }

      it 'does not validate presence' do
        expect(subject).to validate_absence_of(:de_retirement_insurance)
        expect(subject).to validate_absence_of(:de_unemployment_insurance)
        expect(subject).to validate_absence_of(:de_health_insurance)
        expect(subject).to validate_absence_of(:de_church_tax)
      end
    end
  end

  describe '#legal_entity_identifier' do
    let(:contact) { build(:contact_person) }

    it 'validates absensce' do
      expect(subject).to validate_absence_of(:legal_entity_identifier)
    end
  end

  describe '#transparency_register' do
    let(:contact) { build(:contact_person) }

    it 'validates absensce' do
      expect(subject).to validate_absence_of(:transparency_register)
    end
  end
end

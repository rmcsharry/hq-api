# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contact::ContactDecorator do
  describe '#tax_numbers' do
    subject { build(:contact_organization, tax_detail: tax_detail).decorate }

    describe 'when no foreign tax numbers are present' do
      let(:tax_detail) { create :tax_detail, de_tax_number: '21/815/08150' }

      it 'serializes german tax number' do
        expect(subject.tax_numbers).to eq 'DE 21/815/08150'
      end
    end

    describe 'when no foreign tax numbers but a us one are present' do
      let(:tax_detail) { create :tax_detail, de_tax_number: '21/815/08150', us_tax_number: '1234' }

      it 'serializes german tax number' do
        expect(subject.tax_numbers).to eq 'DE 21/815/08150, US 1234'
      end
    end

    describe 'when foreign tax numbers are present' do
      let(:foreign_tax_number) { create :foreign_tax_number, country: 'AT', tax_number: '12/345/678' }
      let(:tax_detail) { create :tax_detail, de_tax_number: '21/815/08150', foreign_tax_numbers: [foreign_tax_number] }

      it 'serializes all tax numbers' do
        expect(subject.tax_numbers).to eq 'DE 21/815/08150, AT 12/345/678'
      end
    end
  end
end

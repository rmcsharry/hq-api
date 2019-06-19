# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AddressDecorator do
  describe '#letter_address' do
    subject do
      build(
        :address,
        organization_name: organization_name,
        street_and_number: 'Manteuffelstr. 77',
        addition: '2. Hinterhof',
        postal_code: 10_999,
        city: 'Berlin',
        country: 'DE'
      ).decorate
    end

    context 'with organization name' do
      let(:organization_name) { 'Sherpas' }

      it 'joins the addresses components with newline characters' do
        expect(subject.letter_address('Addressed Person 1')).to(
          eq(
            <<~ADDRESS.chomp
              Sherpas
              Addressed Person 1
              Manteuffelstr. 77
              2. Hinterhof
              10999
              Berlin
              Deutschland
            ADDRESS
          )
        )
      end

      it 'is capable of inserting multiple addressees' do
        expect(subject.letter_address(['Addressed Person 1', 'Addressed Person 2'])).to(
          eq(
            <<~ADDRESS.chomp
              Sherpas
              Addressed Person 1
              Addressed Person 2
              Manteuffelstr. 77
              2. Hinterhof
              10999
              Berlin
              Deutschland
            ADDRESS
          )
        )
      end
    end

    context 'without organization name' do
      let(:organization_name) { nil }

      it 'joins the addresses components with newline characters' do
        expect(subject.letter_address('Addressed Person 1')).to(
          eq(
            <<~ADDRESS.chomp
              Addressed Person 1
              Manteuffelstr. 77
              2. Hinterhof
              10999
              Berlin
              Deutschland
            ADDRESS
          )
        )
      end
    end
  end
end

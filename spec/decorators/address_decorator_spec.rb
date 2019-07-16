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
        country: country
      ).decorate
    end

    let(:contact1) do
      build(:contact_person, first_name: 'Max', gender: :male, last_name: 'Mustermann', professional_title: 'dr')
    end
    let(:contact2) do
      build(
        :contact_person, first_name: 'Maxi', gender: :female, last_name: 'Musterfrau', professional_title: 'prof_dr'
      )
    end
    let(:organization_name) { 'Sherpas' }
    let(:country) { 'DE' }

    context 'with organization name' do
      it 'joins the addresses components with newline characters' do
        expect(subject.letter_address(addressees: [contact1])).to(
          eq(
            <<~ADDRESS.chomp
              Sherpas
              Herrn Dr. Max Mustermann
              Manteuffelstr. 77
              2. Hinterhof
              10999 Berlin
            ADDRESS
          )
        )
      end

      it 'is capable of inserting multiple addressees' do
        expect(subject.letter_address(addressees: [contact1, contact2])).to(
          eq(
            <<~ADDRESS.chomp
              Sherpas
              Herrn Dr. Max Mustermann
              Frau Prof. Dr. Maxi Musterfrau
              Manteuffelstr. 77
              2. Hinterhof
              10999 Berlin
            ADDRESS
          )
        )
      end
    end

    context 'without organization name and only one contact' do
      let(:organization_name) { nil }

      it 'joins the addresses components with newline characters' do
        expect(subject.letter_address(addressees: [contact1])).to(
          eq(
            <<~ADDRESS.chomp
              Herrn
              Dr. Max Mustermann
              Manteuffelstr. 77
              2. Hinterhof
              10999 Berlin
            ADDRESS
          )
        )
      end
    end

    context 'with country Austria' do
      let(:country) { 'AT' }

      it 'add the country name in German to the address' do
        expect(subject.letter_address(addressees: [contact1])).to(
          eq(
            <<~ADDRESS.chomp
              Sherpas
              Herrn Dr. Max Mustermann
              Manteuffelstr. 77
              2. Hinterhof
              10999 Berlin
              Österreich
            ADDRESS
          )
        )
      end
    end
  end
end

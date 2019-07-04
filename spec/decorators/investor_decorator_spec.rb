# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvestorDecorator do
  subject do
    build(
      :investor,
      amount_total: 100_000,
      primary_contact: primary_contact,
      primary_owner: primary_owner,
      secondary_contact: secondary_contact,
      contact_salutation_primary_owner: contact_salutation_primary_owner,
      contact_salutation_primary_contact: contact_salutation_primary_contact,
      contact_salutation_secondary_contact: contact_salutation_secondary_contact
    ).decorate
  end
  let!(:primary_owner) do
    create(:contact_person, first_name: 'Max', gender: :male, last_name: 'Mustermann', professional_title: 'dr')
  end
  let!(:primary_contact) do
    create(
      :contact_person, first_name: 'Maxi', gender: :female, last_name: 'Musterfrau', professional_title: 'prof_dr'
    )
  end
  let!(:secondary_contact) do
    create(
      :contact_person, first_name: 'Thomas', gender: :male, last_name: 'Makait'
    )
  end

  let!(:contact_salutation_primary_owner) { false }
  let!(:contact_salutation_primary_contact) { false }
  let!(:contact_salutation_secondary_contact) { false }

  describe '#formal_salutation' do
    context 'with primary owner but no contact people' do
      let!(:contact_salutation_primary_owner) { true }

      it 'renders salutation for primary owner' do
        expect(subject.formal_salutation).to eq 'Sehr geehrter Herr Dr. Max Mustermann'
      end
    end

    context 'with primary owner and primary contact person' do
      let!(:contact_salutation_primary_owner) { true }
      let!(:contact_salutation_primary_contact) { true }

      it 'renders salutation for primary owner and primary contact person' do
        expect(subject.formal_salutation).to(
          eq(
            'Sehr geehrter Herr Dr. Max Mustermann, sehr geehrte Frau Prof. Dr. Maxi Musterfrau'
          )
        )
      end
    end

    context 'with primary contact person' do
      let!(:contact_salutation_primary_contact) { true }

      it 'renders salutation for primary contact person' do
        expect(subject.formal_salutation).to eq 'Sehr geehrte Frau Prof. Dr. Maxi Musterfrau'
      end
    end

    context 'with primary and secondary contact person' do
      let!(:contact_salutation_primary_contact) { true }
      let!(:contact_salutation_secondary_contact) { true }

      it 'renders salutation for both contact people' do
        expect(subject.formal_salutation)
          .to(
            eq('Sehr geehrte Frau Prof. Dr. Maxi Musterfrau, sehr geehrter Herr Thomas Makait')
          )
      end
    end

    context 'with primary owner being an organization and primary and secondary contact person' do
      let!(:primary_owner) do
        create(:contact_organization)
      end

      let!(:contact_salutation_primary_owner) { true }
      let!(:contact_salutation_primary_contact) { true }
      let!(:contact_salutation_secondary_contact) { true }

      it 'renders salutation for both contact people but not for the organization' do
        expect(subject.formal_salutation)
          .to(
            eq('Sehr geehrte Frau Prof. Dr. Maxi Musterfrau, sehr geehrter Herr Thomas Makait')
          )
      end
    end

    context 'with primary owner being an organization' do
      let!(:primary_owner) do
        create(:contact_organization)
      end

      let!(:contact_salutation_primary_owner) { true }

      it 'renders a generic salutation' do
        expect(subject.formal_salutation)
          .to(
            eq('Sehr geehrte Damen und Herren')
          )
      end
    end
  end

  describe '#amount_total' do
    let!(:contact_salutation_primary_owner) { true }

    it 'renders total amount in accounting format' do
      expect(subject.amount_total).to eq('EUR 100.000,00')
    end
  end
end

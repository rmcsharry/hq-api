# frozen_string_literal: true

# == Schema Information
#
# Table name: contacts
#
#  comment                       :text
#  commercial_register_number    :string
#  commercial_register_office    :string
#  created_at                    :datetime         not null
#  data_integrity_missing_fields :string           default([]), is an Array
#  data_integrity_score          :decimal(4, 3)    default(0.0)
#  date_of_birth                 :date
#  date_of_death                 :date
#  first_name                    :string
#  gender                        :string
#  id                            :uuid             not null, primary key
#  import_id                     :integer
#  last_name                     :string
#  legal_address_id              :uuid
#  maiden_name                   :string
#  nationality                   :string
#  nobility_title                :string
#  organization_category         :string
#  organization_industry         :string
#  organization_name             :string
#  organization_type             :string
#  place_of_birth                :string
#  primary_contact_address_id    :uuid
#  professional_title            :string
#  type                          :string
#  updated_at                    :datetime         not null
#
# Indexes
#
#  index_contacts_on_legal_address_id            (legal_address_id)
#  index_contacts_on_primary_contact_address_id  (primary_contact_address_id)
#
# Foreign Keys
#
#  fk_rails_...  (legal_address_id => addresses.id)
#  fk_rails_...  (primary_contact_address_id => addresses.id)
#

require 'rails_helper'

RSpec.describe Contact::Person, type: :model do
  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to enumerize(:nobility_title) }
  it { is_expected.to enumerize(:professional_title) }
  it { is_expected.to enumerize(:nationality) }

  describe '#gender' do
    it { is_expected.to validate_presence_of(:gender) }
    it { is_expected.to enumerize(:gender) }
  end

  describe '#date_of_death_greater_or_equal_date_of_birth' do
    subject { build(:contact_person, date_of_birth: date_of_birth, date_of_death: date_of_death) }
    let(:date_of_birth) { 5.days.ago }

    context 'date of death before date of birth' do
      let(:date_of_death) { date_of_birth - 1.day }

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:date_of_death]).to include("can't be before the date of birth")
      end
    end

    context 'date of death before date of birth' do
      let(:date_of_death) { date_of_birth + 1.day }

      it 'is invalid' do
        expect(subject).to be_valid
      end
    end
  end

  describe '#to_s' do
    it 'serializes simple record' do
      contact = create(
        :contact_person,
        first_name: 'First',
        last_name: 'Last',
        gender: 'male'
      )

      expect(contact.to_s).to eq('Herr First Last')
    end

    it 'serializes person with nobility_title' do
      contact = create(
        :contact_person,
        first_name: 'First',
        last_name: 'Last',
        gender: 'male',
        nobility_title: 'baron'
      )

      expect(contact.to_s).to eq('Herr First Freiherr Last')
    end

    it 'serializes person with professional_title' do
      contact = create(
        :contact_person,
        first_name: 'First',
        last_name: 'Last',
        gender: 'male',
        professional_title: 'prof_dr'
      )

      expect(contact.to_s).to eq('Herr Prof. Dr. First Last')
    end

    it 'serializes person with maiden_name' do
      contact = create(
        :contact_person,
        first_name: 'First',
        last_name: 'Last',
        maiden_name: 'Maiden',
        gender: 'male'
      )

      expect(contact.to_s).to eq('Herr First Last (Maiden)')
    end
  end
end

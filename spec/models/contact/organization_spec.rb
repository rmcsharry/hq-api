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
#  index_contacts_on_data_integrity_score        (data_integrity_score)
#  index_contacts_on_legal_address_id            (legal_address_id)
#  index_contacts_on_primary_contact_address_id  (primary_contact_address_id)
#
# Foreign Keys
#
#  fk_rails_...  (legal_address_id => addresses.id)
#  fk_rails_...  (primary_contact_address_id => addresses.id)
#

require 'rails_helper'

RSpec.describe Contact::Organization, type: :model do
  it { is_expected.to validate_presence_of(:organization_name) }

  it { is_expected.to enumerize(:organization_type) }
  it { is_expected.to validate_presence_of(:organization_type) }

  describe '#commercial_register_office' do
    context 'commercial_register_number is present' do
      subject { build(:contact_organization, commercial_register_number: 'HRB 123456 B') }

      it 'validates presence' do
        expect(subject).to validate_presence_of(:commercial_register_office)
      end
    end
  end

  describe '#commercial_register_number' do
    context 'commercial_register_office is present' do
      subject { build(:contact_organization, commercial_register_office: 'Amtsgericht Berlin-Charlottenburg') }

      it 'validates presence' do
        expect(subject).to validate_presence_of(:commercial_register_number)
      end
    end
  end

  describe '#to_s' do
    subject { build(:contact_organization, organization_name: 'ACME Corporation GmbH') }

    it 'serializes simple record' do
      expect(subject.to_s).to eq('ACME Corporation GmbH')
    end
  end
end

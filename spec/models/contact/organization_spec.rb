# frozen_string_literal: true

# == Schema Information
#
# Table name: contacts
#
#  id                         :uuid             not null, primary key
#  first_name                 :string
#  last_name                  :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  type                       :string
#  comment                    :text
#  gender                     :string
#  nobility_title             :string
#  professional_title         :string
#  maiden_name                :string
#  date_of_birth              :date
#  date_of_death              :date
#  nationality                :string
#  organization_name          :string
#  organization_type          :string
#  organization_category      :string
#  organization_industry      :string
#  commercial_register_number :string
#  commercial_register_office :string
#  legal_address_id           :uuid
#  primary_contact_address_id :uuid
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
end

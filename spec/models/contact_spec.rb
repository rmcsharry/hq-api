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

RSpec.describe Contact, type: :model do
  it { is_expected.to have_many(:addresses) }
  it { is_expected.to have_many(:contact_details) }
  it { is_expected.to have_many(:mandate_members) }
  it { is_expected.to have_many(:mandates) }

  describe '#compliance_detail' do
    it { is_expected.to have_one(:compliance_detail) }
  end

  describe '#tax_detail' do
    it { is_expected.to have_one(:tax_detail) }
  end

  describe '#legal_address' do
    it { is_expected.to belong_to(:legal_address).optional }
  end

  describe '#primary_contact_address' do
    it { is_expected.to belong_to(:primary_contact_address).optional }
  end

  describe '#activities' do
    it { is_expected.to have_and_belong_to_many(:activities) }
  end
end

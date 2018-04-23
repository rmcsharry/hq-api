# frozen_string_literal: true

# == Schema Information
#
# Table name: organization_members
#
#  id              :uuid             not null, primary key
#  role            :string           not null
#  organization_id :uuid             not null
#  contact_id      :uuid             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_organization_members_on_contact_id       (contact_id)
#  index_organization_members_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => contacts.id)
#

require 'rails_helper'

RSpec.describe OrganizationMember, type: :model do
  describe '#role' do
    it { is_expected.to respond_to(:role) }
    it { is_expected.to validate_presence_of(:role) }
  end

  describe '#organization' do
    it { is_expected.to belong_to(:organization).required }
  end

  describe '#contact' do
    it { is_expected.to belong_to(:contact).required }
  end
end

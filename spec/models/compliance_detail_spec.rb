# frozen_string_literal: true

# == Schema Information
#
# Table name: compliance_details
#
#  contact_id          :uuid
#  created_at          :datetime         not null
#  id                  :uuid             not null, primary key
#  kagb_classification :string
#  occupation_role     :string
#  occupation_title    :string
#  politically_exposed :boolean          default(FALSE), not null
#  retirement_age      :integer
#  updated_at          :datetime         not null
#  wphg_classification :string
#
# Indexes
#
#  index_compliance_details_on_contact_id  (contact_id)
#
# Foreign Keys
#
#  fk_rails_...  (contact_id => contacts.id)
#

require 'rails_helper'

RSpec.describe ComplianceDetail, type: :model do
  describe '#contact' do
    it { is_expected.to belong_to(:contact).required }
  end

  describe '#wphg_classification' do
    it { is_expected.to validate_presence_of(:wphg_classification) }
    it { is_expected.to enumerize(:wphg_classification) }
  end

  describe '#kagb_classification' do
    it { is_expected.to validate_presence_of(:kagb_classification) }
    it { is_expected.to enumerize(:kagb_classification) }
  end

  describe '#occupation_role' do
    it { is_expected.to enumerize(:occupation_role) }
  end
end

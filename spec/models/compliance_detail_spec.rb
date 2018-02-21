# == Schema Information
#
# Table name: compliance_details
#
#  id                  :uuid             not null, primary key
#  wphg_classification :string
#  kagb_classification :string
#  politically_exposed :boolean          default(FALSE), not null
#  occupation_role     :string
#  occupation_title    :string
#  retirement_age      :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  contact_id          :uuid
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
    it { is_expected.to belong_to(:contact) }
    it { is_expected.to validate_presence_of(:contact) }
  end

  describe '#wphg_classification' do
    it { is_expected.to validate_presence_of(:wphg_classification) }
    it { is_expected.to enumerize(:wphg_classification) }
  end

  describe '#kagb_classification' do
    it { is_expected.to validate_presence_of(:kagb_classification) }
    it { is_expected.to enumerize(:kagb_classification) }
  end
end

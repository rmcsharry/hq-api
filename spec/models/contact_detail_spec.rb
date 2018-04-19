# frozen_string_literal: true

# == Schema Information
#
# Table name: contact_details
#
#  id         :uuid             not null, primary key
#  type       :string
#  category   :string
#  value      :string
#  primary    :boolean          default(FALSE), not null
#  contact_id :uuid
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_contact_details_on_contact_id  (contact_id)
#
# Foreign Keys
#
#  fk_rails_...  (contact_id => contacts.id)
#

require 'rails_helper'

RSpec.describe ContactDetail, type: :model do
  describe '#contact' do
    it { is_expected.to belong_to(:contact).required }
  end

  describe '#category' do
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to enumerize(:category) }
  end

  describe '#value' do
    it { is_expected.to validate_presence_of(:value) }
  end
end

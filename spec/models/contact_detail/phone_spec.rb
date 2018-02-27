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

RSpec.describe ContactDetail::Phone, type: :model do
  subject { build(:phone) }

  describe '#value' do
    let(:valid_phone_numbers) { ['+49301234567', '0170-12345678', '88754312'] }
    let(:invalid_phone_numbers) { %w[ABC 0170123456 12] }

    it 'validates phone format' do
      expect(subject).to allow_values(*valid_phone_numbers).for(:value)
      expect(subject).not_to allow_values(*invalid_phone_numbers).for(:value)
    end
  end
end

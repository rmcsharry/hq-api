# frozen_string_literal: true

# == Schema Information
#
# Table name: contact_details
#
#  category   :string
#  contact_id :uuid
#  created_at :datetime         not null
#  id         :uuid             not null, primary key
#  primary    :boolean          default(FALSE), not null
#  type       :string
#  updated_at :datetime         not null
#  value      :string
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

RSpec.describe ContactDetail::Fax, type: :model do
  subject { build(:fax) }

  describe '#value' do
    let(:valid_fax_numbers) { ['+49301234567', '0170-12345678', '88754312'] }
    let(:invalid_fax_numbers) { %w[ABC 0170123456 12] }

    it 'validates fax format' do
      expect(subject).to allow_values(*valid_fax_numbers).for(:value)
      expect(subject).not_to allow_values(*invalid_fax_numbers).for(:value)
    end
  end
end

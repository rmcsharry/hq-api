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

RSpec.describe ContactDetail::Email, type: :model do
  subject { build(:email) }

  describe '#value' do
    let(:valid_emails) { ['test@test.de', 'test@test.co.uk', 'test123-abc.abc@test.de', 'test+test@test.de'] }
    let(:invalid_emails) { ['test test@test.de', 'test', 'test@test', '@test.co.uk', 'test\test@test.de'] }

    it 'validates email format' do
      expect(subject).to allow_values(*valid_emails).for(:value)
      expect(subject).not_to allow_values(*invalid_emails).for(:value)
    end

    it 'downcases email before validation' do
      subject.value = 'TesT@teSt.DE'
      subject.valid?
      expect(subject.value).to eq 'test@test.de'
    end
  end
end

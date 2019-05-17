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

  describe '#primary', bullet: false do
    let(:contact) { create(:contact_person) }
    let!(:old_email) { create(:email, primary: true, contact: contact) }
    let!(:old_phone) { create(:phone, primary: true, contact: contact) }

    context 'when primary contact detail is created' do
      subject { build(:email, primary: true, contact: contact) }

      it 'marks others as non-primary' do
        expect(old_email.primary).to be true
        subject.save!
        expect(old_email.reload.primary).to be false
        expect(subject.reload.primary).to be true
        expect(old_phone.reload.primary).to be true
      end
    end

    context 'when primary contact detail is updated' do
      subject { create(:email, primary: false, contact: contact) }

      it 'marks others as non-primary' do
        expect(old_email.primary).to be true
        subject.primary = true
        subject.save!
        expect(old_email.reload.primary).to be false
        expect(subject.reload.primary).to be true
        expect(old_phone.reload.primary).to be true
      end
    end
  end

  describe '#to_s' do
    it 'serializes simple record' do
      contact_detail = create :email, value: 'foo@example.com'

      expect(contact_detail.to_s).to eq('foo@example.com')
    end
  end
end

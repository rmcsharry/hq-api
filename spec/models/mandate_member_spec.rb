# frozen_string_literal: true

# == Schema Information
#
# Table name: mandate_members
#
#  comment     :text
#  contact_id  :uuid
#  created_at  :datetime         not null
#  id          :uuid             not null, primary key
#  mandate_id  :uuid
#  member_type :string
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_mandate_members_on_contact_id  (contact_id)
#  index_mandate_members_on_mandate_id  (mandate_id)
#
# Foreign Keys
#
#  fk_rails_...  (contact_id => contacts.id)
#  fk_rails_...  (mandate_id => mandates.id)
#

require 'rails_helper'

RSpec.describe MandateMember, type: :model do
  describe '#member_type' do
    it { is_expected.to validate_presence_of(:member_type) }
    it { is_expected.to enumerize(:member_type) }
  end

  describe '#mandate' do
    it { is_expected.to belong_to(:mandate).required }
  end

  describe '#contact' do
    it { is_expected.to belong_to(:contact).required }
  end

  describe '#comment' do
    it { is_expected.to respond_to(:comment) }
  end

  describe '#mandate_contact_member_type_unique' do
    subject { build(:mandate_member) }
    it 'is_unique' do
      expect(subject).to(
        validate_uniqueness_of(:contact_id)
          .scoped_to(%i[mandate_id member_type])
          .with_message('should occur only once per mandate and member type')
          .case_insensitive
      )
    end
  end

  describe '#member_type' do
    let(:mandate) { create(:mandate, mandate_members: []) }
    subject { build(:mandate_member, mandate: mandate) }

    it 'is unique if it is in MandateMember::UNIQUE_MEMBER_TYPES' do
      MandateMember::UNIQUE_MEMBER_TYPES.each do |unique_member_type|
        subject.member_type = unique_member_type
        subject.save

        expect(subject).to(
          validate_uniqueness_of(:member_type)
            .scoped_to(:mandate_id)
            .with_message('should occur only once per mandate')
        )
      end
    end

    it 'is not unique if it is something else' do
      subject.member_type = MandateMember::NON_UNIQUE_MEMBER_TYPES.sample

      expect(subject).not_to validate_uniqueness_of(:member_type)
    end
  end
end

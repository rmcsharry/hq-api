# frozen_string_literal: true

# == Schema Information
#
# Table name: inter_person_relationships
#
#  id               :uuid             not null, primary key
#  role             :string           not null
#  target_person_id :uuid             not null
#  source_person_id :uuid             not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_inter_person_relationships_on_source_person_id  (source_person_id)
#  index_inter_person_relationships_on_target_person_id  (target_person_id)
#
# Foreign Keys
#
#  fk_rails_...  (source_person_id => contacts.id)
#  fk_rails_...  (target_person_id => contacts.id)
#

require 'rails_helper'

RSpec.describe InterPersonRelationship, type: :model do
  describe '#role' do
    it { is_expected.to respond_to(:role) }
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_inclusion_of(:role).in_array(InterPersonRelationship::AVAILABLE_ROLES) }
  end

  describe '#target_person' do
    it { is_expected.to belong_to(:target_person).required }
  end

  describe '#source_person' do
    it { is_expected.to belong_to(:source_person).required }
  end
end

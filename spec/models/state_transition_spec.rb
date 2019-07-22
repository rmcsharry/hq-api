# frozen_string_literal: true

# == Schema Information
#
# Table name: state_transitions
#
#  created_at   :datetime
#  event        :string
#  id           :uuid             not null, primary key
#  is_successor :boolean
#  state        :string           not null
#  subject_id   :uuid             not null
#  subject_type :string           not null
#  user_id      :uuid
#
# Indexes
#
#  index_state_transitions_on_subject_and_created_at       (subject_type,subject_id,created_at)
#  index_state_transitions_on_subject_type_and_subject_id  (subject_type,subject_id)
#

require 'rails_helper'

RSpec.describe StateTransition, type: :model do
  describe '#user' do
    it { is_expected.to belong_to(:user).optional }
  end

  describe '#subject' do
    it { is_expected.to belong_to(:subject).required }
  end

  describe '#state' do
    it { is_expected.to validate_presence_of(:state) }
  end
end

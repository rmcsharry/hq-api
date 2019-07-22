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

# Defines the StateTransition model
class StateTransition < ApplicationRecord
  belongs_to :user, inverse_of: :created_state_transitions, optional: true
  belongs_to :subject, polymorphic: true, inverse_of: :state_transitions

  validates :state, presence: true
end

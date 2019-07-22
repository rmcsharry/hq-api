# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::StateTransitionResource, type: :resource do
  let(:mandate) { create(:mandate) }
  subject { described_class.new(mandate.state_transitions.first, {}) }

  it { is_expected.to have_attribute :created_at }
  it { is_expected.to have_attribute :event }
  it { is_expected.to have_attribute :is_successor }
  it { is_expected.to have_attribute :state }

  it { is_expected.to have_one :user }
  it { is_expected.to have_one :subject }

  it { is_expected.to filter(:subject_id) }

  it { is_expected.to have_sortable_field :created_at }
end

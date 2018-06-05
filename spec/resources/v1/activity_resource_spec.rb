# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::ActivityResource, type: :resource do
  let(:activity) { create(:activity_call) }
  subject { described_class.new(activity, {}) }

  it { is_expected.to have_attribute :activity_type }
  it { is_expected.to have_attribute :created_at }
  it { is_expected.to have_attribute :started_at }
  it { is_expected.to have_attribute :ended_at }
  it { is_expected.to have_attribute :title }
  it { is_expected.to have_attribute :description }
  it { is_expected.to have_attribute :updated_at }

  it { is_expected.to have_many(:mandates) }
  it { is_expected.to have_many(:contacts) }
  it { is_expected.to have_many(:documents) }

  it { is_expected.to filter(:activity_type) }
  it { is_expected.to filter(:contact_id) }
  it { is_expected.to filter(:mandate_id) }
  it { is_expected.to filter(:mandate_group_id) }
end

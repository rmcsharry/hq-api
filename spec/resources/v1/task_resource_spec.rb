# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::TaskResource, type: :resource do
  let(:task) { create(:task) }
  subject { described_class.new(task, {}) }

  it { is_expected.to have_attribute :created_at }
  it { is_expected.to have_attribute :description }
  it { is_expected.to have_attribute :due_at }
  it { is_expected.to have_attribute :finished_at }
  it { is_expected.to have_attribute :state }
  it { is_expected.to have_attribute :task_type }
  it { is_expected.to have_attribute :title }

  it { is_expected.to have_one(:creator) }
  it { is_expected.to have_one(:finisher) }
  it { is_expected.to have_one(:subject) }
  it { is_expected.to have_one(:linked_object) }

  it { is_expected.to have_many(:assignees) }

  it { is_expected.to filter(:user_id) }
  it { is_expected.to filter(:creator_id) }
  it { is_expected.to filter(:finisher_id) }
  it { is_expected.to filter(:state) }
end

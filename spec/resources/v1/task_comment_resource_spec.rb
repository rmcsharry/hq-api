# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::TaskCommentResource, type: :resource do
  let(:task_comment) { create(:task_comment) }
  subject { described_class.new(task_comment, {}) }

  it { is_expected.to have_attribute :comment }
  it { is_expected.to have_attribute :created_at }
  it { is_expected.to have_attribute :updated_at }

  it { is_expected.to have_one(:contact) }
  it { is_expected.to have_one(:task) }
  it { is_expected.to have_one(:user) }

  it { is_expected.to filter(:task_id) }
end

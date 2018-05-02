# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::UserGroupResource, type: :resource do
  let(:user_group) { create(:user_group) }
  subject { described_class.new(user_group, {}) }

  it { is_expected.to have_attribute :comment }
  it { is_expected.to have_attribute :name }
  it { is_expected.to have_attribute :roles }
  it { is_expected.to have_attribute :updated_at }
  it { is_expected.to have_attribute :user_count }

  it { is_expected.to have_many(:users) }
  it { is_expected.to have_many(:mandate_groups) }

  it { is_expected.to filter(:user_id) }
  it { is_expected.to filter(:name) }
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::UserGroupResource, type: :resource do
  let(:user_group) { create(:user_group) }
  subject { described_class.new(user_group, {}) }

  it { is_expected.to have_attribute :name }
  it { is_expected.to have_attribute :comment }

  it { is_expected.to have_many(:users) }
  it { is_expected.to have_many(:mandate_groups) }
end

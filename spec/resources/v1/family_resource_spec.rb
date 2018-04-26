# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::FamilyResource, type: :resource do
  let(:mandate_group) { create(:mandate_group) }
  subject { described_class.new(mandate_group, {}) }

  it { is_expected.to have_attribute :name }
  it { is_expected.to have_attribute :mandate_count }
  it { is_expected.to have_attribute :updated_at }

  it { is_expected.to have_many(:mandates) }
  it { is_expected.to have_many(:user_groups) }

  it { is_expected.to filter(:name) }
end

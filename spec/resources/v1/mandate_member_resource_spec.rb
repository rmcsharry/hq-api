# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::MandateMemberResource, type: :resource do
  let(:mandate_member) { create(:mandate_member) }
  subject { described_class.new(mandate_member, {}) }

  it { is_expected.to have_attribute :comment }
  it { is_expected.to have_attribute :member_type }

  it { is_expected.to have_one(:contact) }
  it { is_expected.to have_one(:mandate) }

  it { is_expected.to filter(:is_owner) }
  it { is_expected.to filter(:mandate_id) }
  it { is_expected.to filter(:member_type) }
end

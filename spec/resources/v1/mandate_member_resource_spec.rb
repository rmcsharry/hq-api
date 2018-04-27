# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::MandateMemberResource, type: :resource do
  let(:mandate_member) { create(:mandate_member) }
  subject { described_class.new(mandate_member, {}) }

  it { is_expected.to have_attribute :member_type }
  it { is_expected.to have_attribute :start_date }
  it { is_expected.to have_attribute :end_date }

  it { is_expected.to have_one(:contact) }
  it { is_expected.to have_one(:mandate) }

  it { is_expected.to filter(:is_owner) }
end

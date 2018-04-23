# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::OrganizationMemberResource, type: :resource do
  let(:organization_member) { create(:organization_member) }
  subject { described_class.new(organization_member, {}) }

  it { is_expected.to have_attribute :role }

  it { is_expected.to have_one(:contact) }
  it { is_expected.to have_one(:organization) }
end

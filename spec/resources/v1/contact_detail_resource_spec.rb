# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::ContactDetailResource, type: :resource do
  let(:phone) { create(:phone) }
  subject { described_class.new(phone, {}) }

  it { is_expected.to have_attribute :category }
  it { is_expected.to have_attribute :value }
  it { is_expected.to have_attribute :primary }

  it { is_expected.to have_one(:contact) }

  it { is_expected.to filter(:contact_id) }
end

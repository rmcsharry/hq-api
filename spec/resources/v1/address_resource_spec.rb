# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::AddressResource, type: :resource do
  let(:address) { create(:address) }
  subject { described_class.new(address, {}) }

  it { is_expected.to have_attribute :addition }
  it { is_expected.to have_attribute :category }
  it { is_expected.to have_attribute :city }
  it { is_expected.to have_attribute :country }
  it { is_expected.to have_attribute :postal_code }
  it { is_expected.to have_attribute :state }
  it { is_expected.to have_attribute :street_and_number }
  it { is_expected.to have_attribute :legal_address }
  it { is_expected.to have_attribute :primary_contact_address }

  it { is_expected.to have_one(:contact) }

  it { is_expected.to filter(:contact_id) }
end

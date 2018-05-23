# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::ForeignTaxNumberResource, type: :resource do
  let(:foreign_tax_number) { create(:foreign_tax_number) }
  subject { described_class.new(foreign_tax_number, {}) }

  it { is_expected.to have_attribute :tax_number }
  it { is_expected.to have_attribute :country }

  it { is_expected.to have_one(:tax_detail) }

  it { is_expected.to filter(:tax_detail_id) }
  it { is_expected.to filter(:"tax_detail.contact_id") }
end

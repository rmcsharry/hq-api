# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::BankAccountResource, type: :resource do
  let(:bank_account) { create(:bank_account) }
  subject { described_class.new(bank_account, {}) }

  it { is_expected.to have_attribute :account_type }
  it { is_expected.to have_attribute :owner }
  it { is_expected.to have_attribute :bank_account_number }
  it { is_expected.to have_attribute :bank_routing_number }
  it { is_expected.to have_attribute :iban }
  it { is_expected.to have_attribute :bic }
  it { is_expected.to have_attribute :currency }
  it { is_expected.to have_attribute :alternative_investments }

  it { is_expected.to have_one(:owner) }
  it { is_expected.to have_one(:bank).with_class_name('Contact') }

  it { is_expected.to filter(:alternative_investments) }
  it { is_expected.to filter(:owner_id) }
end

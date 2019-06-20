# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::FundResource, type: :resource do
  let(:fund) { create(:fund) }
  subject { described_class.new(fund, {}) }

  it { is_expected.to have_attribute :fund_type }
  it { is_expected.to have_attribute :comment }
  it { is_expected.to have_attribute :commercial_register_number }
  it { is_expected.to have_attribute :commercial_register_office }
  it { is_expected.to have_attribute :company }
  it { is_expected.to have_attribute :currency }
  it { is_expected.to have_attribute :de_central_bank_id }
  it { is_expected.to have_attribute :de_foreign_trade_regulations_id }
  it { is_expected.to have_attribute :dpi }
  it { is_expected.to have_attribute :duration }
  it { is_expected.to have_attribute :duration_extension }
  it { is_expected.to have_attribute :global_intermediary_identification_number }
  it { is_expected.to have_attribute :holdings_last_update_at }
  it { is_expected.to have_attribute :irr }
  it { is_expected.to have_attribute :issuing_year }
  it { is_expected.to have_attribute :name }
  it { is_expected.to have_attribute :psplus_asset_id }
  it { is_expected.to have_attribute :region }
  it { is_expected.to have_attribute :state }
  it { is_expected.to have_attribute :strategy }
  it { is_expected.to have_attribute :tax_id }
  it { is_expected.to have_attribute :tax_office }
  it { is_expected.to have_attribute :total_called_amount }
  it { is_expected.to have_attribute :total_distributions_amount }
  it { is_expected.to have_attribute :total_open_amount }
  it { is_expected.to have_attribute :total_signed_amount }
  it { is_expected.to have_attribute :tvpi }
  it { is_expected.to have_attribute :updated_at }
  it { is_expected.to have_attribute :us_employer_identification_number }

  it { is_expected.to have_many(:addresses) }
  it { is_expected.to have_many(:bank_accounts) }
  it { is_expected.to have_many(:documents) }
  it { is_expected.to have_many(:fund_cashflows) }
  it { is_expected.to have_many(:investor_cashflows) }
  it { is_expected.to have_many(:fund_reports) }
  it { is_expected.to have_many(:investor_reports) }
  it { is_expected.to have_many(:fund_templates) }
  it { is_expected.to have_many(:investors) }
  it { is_expected.to have_one(:capital_management_company).with_class_name('Contact') }
  it { is_expected.to have_one(:legal_address).with_class_name('Address') }
  it { is_expected.to have_one(:primary_contact_address).with_class_name('Address') }

  it { is_expected.to filter(:"capital_management_company.organization_name") }
  it { is_expected.to filter(:fund_type) }
  it { is_expected.to filter(:commercial_register_number) }
  it { is_expected.to filter(:commercial_register_office) }
  it { is_expected.to filter(:currency) }
  it { is_expected.to filter(:issuing_year) }
  it { is_expected.to filter(:name) }
  it { is_expected.to filter(:owner_id) }
  it { is_expected.to filter(:psplus_asset_id) }
  it { is_expected.to filter(:region) }
  it { is_expected.to filter(:state) }
  it { is_expected.to filter(:strategy) }
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::InvestorResource, type: :resource do
  let(:investor) { create(:investor) }
  subject { described_class.new(investor, {}) }

  it { is_expected.to have_attribute :amount_called }
  it { is_expected.to have_attribute :amount_open }
  it { is_expected.to have_attribute :amount_total }
  it { is_expected.to have_attribute :amount_total_distribution }
  it { is_expected.to have_attribute :capital_account_number }
  it { is_expected.to have_attribute :contactSalutationPrimaryOwner }
  it { is_expected.to have_attribute :contactSalutationPrimaryContact }
  it { is_expected.to have_attribute :contactSalutationSecondaryContact }
  it { is_expected.to have_attribute :current_value }
  it { is_expected.to have_attribute :dpi }
  it { is_expected.to have_attribute :investment_date }
  it { is_expected.to have_attribute :irr }
  it { is_expected.to have_attribute :state }
  it { is_expected.to have_attribute :tvpi }
  it { is_expected.to have_attribute :updated_at }

  it { is_expected.to have_one :bank_account }
  it { is_expected.to have_one :contact_address }
  it { is_expected.to have_one :contact_email }
  it { is_expected.to have_one :contact_phone }
  it { is_expected.to have_one :fund }
  it { is_expected.to have_one :fund_subscription_agreement }
  it { is_expected.to have_one :legal_address }
  it { is_expected.to have_one :mandate }
  it { is_expected.to have_one :primary_owner }
  it { is_expected.to have_one(:primary_contact).with_class_name('Contact') }
  it { is_expected.to have_one(:secondary_contact).with_class_name('Contact') }

  it { is_expected.to have_many :documents }
  it { is_expected.to have_many :investor_reports }

  it { is_expected.to filter :fund_id }
  it { is_expected.to filter :mandate_id }
  it { is_expected.to filter :fund_report_id }
end

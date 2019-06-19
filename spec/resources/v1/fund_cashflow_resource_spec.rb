# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::FundCashflowResource, type: :resource do
  let(:fund_cashflow) { create(:fund_cashflow) }
  subject { described_class.new(fund_cashflow, {}) }

  it { is_expected.to have_attribute :description_bottom }
  it { is_expected.to have_attribute :description_top }
  it { is_expected.to have_attribute :investor_count }
  it { is_expected.to have_attribute :number }
  it { is_expected.to have_attribute :state }
  it { is_expected.to have_attribute :net_cashflow_amount }
  it { is_expected.to have_attribute :fund_cashflow_type }
  it { is_expected.to have_attribute :valuta_date }

  it { is_expected.to have_one :fund }
  it { is_expected.to have_many :investor_cashflows }

  it { is_expected.to filter :fund_id }

  it { is_expected.to have_sortable_field :net_cashflow_amount }
  it { is_expected.to have_sortable_field :fund_cashflow_type }
  it { is_expected.to have_sortable_field :state }
end

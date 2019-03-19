# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::FundReportResource, type: :resource do
  let(:fund_report) { create(:fund_report) }
  subject { described_class.new(fund_report, {}) }

  it { is_expected.to have_attribute :description }
  it { is_expected.to have_attribute :investor_count }
  it { is_expected.to have_attribute :irr }
  it { is_expected.to have_attribute :valuta_date }

  it { is_expected.to have_one :fund }

  it { is_expected.to have_many :investor_reports }

  it { is_expected.to filter(:fund_id) }

  it { is_expected.to have_sortable_field :investor_count }
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::InvestorReportResource, type: :resource do
  let(:investor_report) { create(:investor_report) }
  subject { described_class.new(investor_report, {}) }

  it { is_expected.to have_one :fund_report }
  it { is_expected.to have_one :investor }
end

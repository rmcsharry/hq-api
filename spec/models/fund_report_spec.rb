# frozen_string_literal: true

# == Schema Information
#
# Table name: fund_reports
#
#  created_at  :datetime         not null
#  description :text
#  dpi         :decimal(20, 10)
#  fund_id     :uuid
#  id          :uuid             not null, primary key
#  irr         :decimal(20, 10)
#  rvpi        :decimal(20, 10)
#  tvpi        :decimal(20, 10)
#  updated_at  :datetime         not null
#  valuta_date :date
#
# Indexes
#
#  index_fund_reports_on_fund_id  (fund_id)
#
# Foreign Keys
#
#  fk_rails_...  (fund_id => funds.id)
#

require 'rails_helper'

RSpec.describe FundReport, type: :model do
  describe '#fund' do
    it { is_expected.to belong_to(:fund).required }
  end

  describe '#irr' do
    it { is_expected.to respond_to(:irr) }
  end

  describe '#rvpi' do
    it { is_expected.to respond_to(:rvpi) }
  end

  describe '#tvpi' do
    it { is_expected.to respond_to(:tvpi) }
  end

  describe '#dpi' do
    it { is_expected.to respond_to(:dpi) }
  end

  describe '#description' do
    it { is_expected.to respond_to(:description) }
    it { is_expected.to validate_presence_of(:description) }
  end

  describe '#valuta_date' do
    it { is_expected.to respond_to(:valuta_date) }
    it { is_expected.to validate_presence_of(:valuta_date) }
  end
end

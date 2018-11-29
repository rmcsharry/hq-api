# frozen_string_literal: true

# == Schema Information
#
# Table name: fund_reports
#
#  id          :uuid             not null, primary key
#  valuta_date :date
#  irr         :decimal(20, 10)
#  description :text
#  fund_id     :uuid
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
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

  describe '#description' do
    it { is_expected.to respond_to(:description) }
    it { is_expected.to validate_presence_of(:description) }
  end

  describe '#valuta_date' do
    it { is_expected.to respond_to(:valuta_date) }
    it { is_expected.to validate_presence_of(:valuta_date) }
  end
end

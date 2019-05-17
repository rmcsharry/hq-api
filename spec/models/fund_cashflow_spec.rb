# frozen_string_literal: true

# == Schema Information
#
# Table name: fund_cashflows
#
#  created_at  :datetime         not null
#  fund_id     :uuid
#  id          :uuid             not null, primary key
#  number      :integer
#  updated_at  :datetime         not null
#  valuta_date :date
#
# Indexes
#
#  index_fund_cashflows_on_fund_id  (fund_id)
#
# Foreign Keys
#
#  fk_rails_...  (fund_id => funds.id)
#

require 'rails_helper'

RSpec.describe FundCashflow, type: :model, bullet: false do
  subject { create(:fund_cashflow, fund: fund) }

  let(:fund) { create(:fund) }

  it { is_expected.to belong_to(:fund).required }
  it { is_expected.to have_many(:investor_cashflows) }

  describe '#number' do
    it { is_expected.to respond_to(:number) }
    it { is_expected.to validate_presence_of(:valuta_date) }
    it {
      validate_uniqueness_of(:number).scoped_to(:fund_id)
                                     .with_message('should occur only once per fund')
    }

    context 'without pre-existing fund cashflow' do
      it 'get assigned number 1' do
        expect(subject.number).to eq 1
      end
    end

    context 'with pre-existing fund cashflows' do
      let!(:cashflow1) { create(:fund_cashflow, fund: fund, number: 1) }
      let!(:cashflow2) { create(:fund_cashflow, fund: fund, number: 3) }

      it 'gets assigned number 4' do
        expect(subject.number).to eq 4
      end
    end
  end

  describe '#valuta_date' do
    it { is_expected.to respond_to(:valuta_date) }
    it { is_expected.to validate_presence_of(:valuta_date) }
  end

  describe '#fund_cashflow_type and #net_cashflow_amount' do
    context 'with net distribution investor cashflows' do
      let!(:investor_cashflow1) { create(:investor_cashflow, :distribution, fund_cashflow: subject, fund: fund) }
      let!(:investor_cashflow2) { create(:investor_cashflow, :distribution, fund_cashflow: subject, fund: fund) }

      it 'is classified as distribution' do
        expect(subject.fund_cashflow_type).to eq :distribution
        expect(subject.net_cashflow_amount).to eq 1_800_000
      end
    end

    context 'with net capital call investor cashflows' do
      let!(:investor_cashflow1) { create(:investor_cashflow, :capital_call, fund_cashflow: subject, fund: fund) }
      let!(:investor_cashflow2) { create(:investor_cashflow, :capital_call, fund_cashflow: subject, fund: fund) }

      it 'is classified as capital_call' do
        expect(subject.fund_cashflow_type).to eq :capital_call
        expect(subject.net_cashflow_amount).to eq(-600_000)
      end
    end
  end

  describe '#state' do
    context 'with all investor cashflows finished' do
      let!(:investor_cashflow1) { create(:investor_cashflow, state: :finished, fund_cashflow: subject, fund: fund) }
      let!(:investor_cashflow2) { create(:investor_cashflow, state: :finished, fund_cashflow: subject, fund: fund) }

      it 'is classified as finished' do
        expect(subject.state).to eq :finished
      end
    end

    context 'with one investor cashflow open' do
      let!(:investor_cashflow1) { create(:investor_cashflow, state: :finished, fund_cashflow: subject, fund: fund) }
      let!(:investor_cashflow2) { create(:investor_cashflow, state: :open, fund_cashflow: subject, fund: fund) }

      it 'is classified as open' do
        expect(subject.state).to eq :open
      end
    end
  end
end

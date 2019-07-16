# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvestorCashflowDecorator do
  let!(:fund) { create(:fund, currency: :EUR) }
  let!(:fund_cashflow) { create(:fund_cashflow, fund: fund) }
  let!(:investor) { create(:investor, amount_total: amount_total) }
  let!(:amount_total) { 42 }
  subject do
    build(
      :investor_cashflow,
      capital_call_gross_amount: cashflow_type == :distribution ? 0 : 2,
      distribution_dividends_amount: cashflow_type == :distribution ? 4 : 0,
      fund_cashflow: fund_cashflow,
      investor: investor
    ).decorate
  end

  describe 'formatting of currency values' do
    context 'for distributions' do
      let!(:cashflow_type) { :distribution }

      it 'renders abs of negative value and adds currency to it' do
        expect(subject.net_cashflow_amount).to eq '4,00'
      end
    end

    context 'for capital calls' do
      let!(:cashflow_type) { :capital_call }

      it 'renders value and adds currency to it' do
        expect(subject.net_cashflow_amount).to eq '2,00'
      end
    end
  end

  describe 'formatting of percentage values' do
    let!(:cashflow_type) { :distribution }

    context 'when share is 0.5' do
      let!(:amount_total) { 8 }

      it 'renders 50,0' do
        expect(subject.distribution_dividends_percentage).to eq '50,0'
      end
    end

    context 'when share is 0.\overline{4}' do
      let!(:amount_total) { 9 }

      it 'properly rounds to 44,4' do
        expect(subject.distribution_dividends_percentage).to eq '44,4'
      end
    end

    context 'when share is 0.\overline{36}' do
      let!(:amount_total) { 11 }

      it 'properly rounds to 36,4' do
        expect(subject.distribution_dividends_percentage).to eq '36,4'
      end
    end

    context 'when share is 0.0004' do
      let!(:amount_total) { 10_000 }

      it 'renders "N/A" because it rounds to 0,00' do
        expect(subject.distribution_dividends_percentage).to eq 'N/A'
      end
    end
  end
end

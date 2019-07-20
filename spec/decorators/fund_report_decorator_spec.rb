# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FundReportDecorator do
  let(:irr) { 0.0432 }
  let(:tvpi) { 4.32 }
  let(:rvpi) { 4.32 }
  let(:dpi) { 4.32 }
  subject do
    build(:fund_report, irr: irr, tvpi: tvpi, rvpi: rvpi, dpi: dpi).decorate
  end

  describe 'irr' do
    context 'when irr is 4.32 %' do
      it 'renders 4,3' do
        expect(subject.irr).to eq '4,3'
      end
    end

    context 'when irr is nil' do
      let(:irr) { nil }

      it 'renders N/A' do
        expect(subject.irr).to eq 'N/A'
      end
    end
  end

  describe 'tvpi' do
    context 'when tvpi is 4.32' do
      it 'renders 4,3' do
        expect(subject.tvpi).to eq '4,3'
      end
    end

    context 'when tvpi is nil' do
      let(:tvpi) { nil }

      it 'renders N/A' do
        expect(subject.tvpi).to eq 'N/A'
      end
    end
  end

  describe 'rvpi' do
    context 'when rvpi is 4.32' do
      it 'renders 4,3' do
        expect(subject.rvpi).to eq '4,3'
      end
    end

    context 'when rvpi is nil' do
      let(:rvpi) { nil }

      it 'renders N/A' do
        expect(subject.rvpi).to eq 'N/A'
      end
    end
  end

  describe 'dpi' do
    context 'when dpi is 4.32' do
      it 'renders 4,3' do
        expect(subject.dpi).to eq '4,3'
      end
    end

    context 'when dpi is nil' do
      let(:dpi) { nil }

      it 'renders N/A' do
        expect(subject.dpi).to eq 'N/A'
      end
    end
  end
end

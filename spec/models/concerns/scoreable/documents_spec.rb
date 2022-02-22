# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scoreable::Document, bullet: false do
  describe '#rescore_owner' do
    describe 'for contact_person' do
      subject { create(:contact_person) }
      let!(:document) { build(:document, category: 'kyc') }
      let!(:document_2) { build(:document, category: 'kyc') }

      before do
        document.owner = subject
        subject.documents << document
        subject.save!
        subject.calculate_score
      end

      context 'when rule: a related model property has a specific value (document category == kyc)' do
        it 'is correct when document is added' do
          expect(subject.data_integrity_missing_fields).not_to include('kyc')
          expect(subject.data_integrity_missing_fields.length).to eq(23)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.271)
        end

        context 'when document is removed' do
          before do
            document.destroy
            subject.calculate_score
          end

          it 'scores correctly' do
            expect(subject.data_integrity_missing_fields).to include('kyc')
            expect(subject.data_integrity_missing_fields.length).to eq(24)
            expect(subject.data_integrity_score).to be_within(0.0001).of(0.1626)
          end
        end

        context 'when document is added again' do
          after do
            subject.documents << document_2
            document_2.save!
            document_2.rescore_owner
          end

          it 'is not rescored' do
            expect(subject).not_to receive(:calculate_score)
            expect(subject.data_integrity_score).to be_within(0.0001).of(0.271)
          end
        end
      end
    end

    describe 'for contact_organization' do
      subject { create(:contact_organization) }
      let!(:document) { build(:document, category: 'kyc') }
      let!(:document_2) { build(:document, category: 'kyc') }

      before do
        document.owner = subject
        subject.documents << document
        subject.save!
        subject.calculate_score
      end

      context 'when rule: a related model property has a specific value (document category == kyc)' do
        it 'is correct when document is added' do
          expect(subject.data_integrity_missing_fields).not_to include('kyc')
          expect(subject.data_integrity_missing_fields.length).to eq(20)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.1887)
        end

        context 'when document is removed' do
          before do
            document.destroy
            subject.calculate_score
          end

          it 'scores correctly' do
            expect(subject.data_integrity_missing_fields).to include('kyc')
            expect(subject.data_integrity_missing_fields.length).to eq(21)
            expect(subject.data_integrity_score).to be_within(0.0001).of(0.0943)
          end
        end

        context 'when document is added again' do
          after do
            subject.documents << document_2
            document_2.save!
            document_2.rescore_owner
          end

          it 'is not rescored' do
            expect(subject).not_to receive(:calculate_score)
            expect(subject.data_integrity_score).to be_within(0.0001).of(0.1887)
          end
        end
      end
    end

    describe 'for mandate' do
      subject { create(:mandate) }
      let!(:document) { build(:document, category: 'contract_hq') }
      let!(:document_2) { build(:document, category: 'contract_hq') }

      before do
        document.owner = subject
        subject.documents << document
        subject.save!
        subject.calculate_score
      end

      context 'when rule: a related model property has a specific value (document category == contract_hq)' do
        it 'is correct when document is added' do
          expect(subject.data_integrity_missing_fields).not_to include('contract_hq')
          expect(subject.data_integrity_missing_fields.length).to eq(10)
          expect(subject.data_integrity_score).to be_within(0.0001).of(0.2273)
          expect(subject.data_integrity_partial_score).to be_within(0.0001).of(0.4545)
        end

        context 'when document is removed' do
          before do
            document.destroy
            subject.calculate_score
          end

          it 'scores correctly' do
            expect(subject.data_integrity_missing_fields).to include('contract_hq')
            expect(subject.data_integrity_missing_fields.length).to eq(11)
            expect(subject.data_integrity_score).to be_within(0.0001).of(0.1299)
            expect(subject.data_integrity_partial_score).to be_within(0.0001).of(0.2597)
          end
        end

        context 'when document is added again' do
          after do
            subject.documents << document_2
            document_2.save!
            document_2.rescore_owner
          end

          it 'is not rescored' do
            expect(subject).not_to receive(:calculate_score)
            expect(subject.data_integrity_score).to be_within(0.0001).of(0.2273)
          end
        end
      end
    end
  end
end

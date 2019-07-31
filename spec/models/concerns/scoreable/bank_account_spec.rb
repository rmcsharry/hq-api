# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scoreable::BankAccount, bullet: false do
  describe '#rescore_owner' do
    describe 'for mandate' do
      context 'when bank account changes' do
        let!(:subject) { create(:mandate) }
        let(:bank_account) { build(:bank_account) }
        let!(:bank_account_2) { build(:bank_account) }

        it 'scores correctly when initial bank account is added' do
          bank_account.owner = subject
          bank_account.save!
          subject.reload
          bank_account.rescore_owner

          expect(subject.data_integrity_missing_fields).not_to include('bank-accounts')
          expect(subject.data_integrity_missing_fields.length).to eq(10)
          expect(subject.data_integrity_partial_score).to be_within(0.0001).of(0.3247)
        end

        it 'scores correctly when bank account is destroyed' do
          bank_account.owner = subject
          bank_account.destroy
          bank_account.rescore_owner

          expect(subject.data_integrity_missing_fields).to include('bank-accounts')
          expect(subject.data_integrity_missing_fields.length).to eq(11)
          expect(subject.data_integrity_partial_score).to be_within(0.0001).of(0.2597)
        end

        it 'does not rescore when adding bank account after the first one' do
          bank_account.owner = subject
          bank_account.save!
          bank_account.rescore_owner

          expect(subject).not_to receive(:calculate_score)
          bank_account_2.owner = subject
          bank_account_2.save!
          bank_account_2.rescore_owner
        end

        it 'does not rescore when removing bank accounts except one' do
          bank_account.owner = subject
          bank_account.save!
          bank_account_2.owner = subject
          bank_account_2.save!

          expect(subject).not_to receive(:calculate_score)
          bank_account_2.destroy!
        end
      end
    end
  end
end

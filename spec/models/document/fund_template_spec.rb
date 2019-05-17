# frozen_string_literal: true

# == Schema Information
#
# Table name: documents
#
#  aasm_state  :string           default("created"), not null
#  category    :string           not null
#  created_at  :datetime         not null
#  id          :uuid             not null, primary key
#  name        :string           not null
#  owner_id    :uuid
#  owner_type  :string
#  type        :string
#  updated_at  :datetime         not null
#  uploader_id :uuid             not null
#  valid_from  :date
#  valid_to    :date
#
# Indexes
#
#  index_documents_on_owner_type_and_owner_id  (owner_type,owner_id)
#  index_documents_on_uploader_id              (uploader_id)
#
# Foreign Keys
#
#  fk_rails_...  (uploader_id => users.id)
#

require 'rails_helper'

RSpec.describe Document::FundTemplate, type: :model do
  subject { build(:fund_template_document, category: :fund_capital_call_template) }

  describe '#category' do
    let(:valid_categories) do
      %i[
        fund_capital_call_template
        fund_distribution_template
        fund_quarterly_report_template
        fund_subscription_agreement_template
      ]
    end
    let(:invalid_categories) { %i[contract_hq contract_general invoice performance_report] }

    it 'validates category' do
      expect(subject).to allow_values(*valid_categories).for(:category)
      expect(subject).not_to allow_values(*invalid_categories).for(:category)
    end

    context 'with existing template' do
      let!(:new_fund_template_document) do
        build(:fund_template_document, owner: subject.owner, category: :fund_quarterly_report_template)
      end

      it 'validates uniqueness' do
        # existing templates with the same category are only cleaned up on creation
        new_fund_template_document.save!
        new_fund_template_document.category = :fund_capital_call_template
        expect(new_fund_template_document.valid?).to be_falsey
        expect(new_fund_template_document.errors.messages[:category].first).to eq 'should occur only once per owner'
      end
    end
  end
end

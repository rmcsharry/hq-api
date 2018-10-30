# frozen_string_literal: true

# == Schema Information
#
# Table name: documents
#
#  id          :uuid             not null, primary key
#  name        :string           not null
#  category    :string           not null
#  valid_from  :date
#  valid_to    :date
#  uploader_id :uuid             not null
#  owner_type  :string           not null
#  owner_id    :uuid             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  type        :string
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
  subject { build(:fund_template_document) }

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
  end
end
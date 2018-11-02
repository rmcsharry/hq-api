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

class Document
  # Defines the Document model for fund template documents
  class FundTemplate < Document
    def self.policy_class
      DocumentPolicy
    end

    CATEGORIES = %i[
      fund_capital_call_template
      fund_distribution_template
      fund_quarterly_report_template
      fund_subscription_agreement_template
    ].freeze

    enumerize :category, in: CATEGORIES, scope: true
  end
end

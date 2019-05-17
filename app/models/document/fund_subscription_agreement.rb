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

class Document
  # Defines the Document model for signed fund subscription agreement documents
  class FundSubscriptionAgreement < Document
    def self.policy_class
      DocumentPolicy
    end

    CATEGORIES = %i[
      fund_subscription_agreement
    ].freeze

    enumerize :category, in: CATEGORIES, scope: true

    validates(
      :category,
      uniqueness: { scope: %i[owner],
                    message: 'should occur only once per owner', case_sensitive: false }
    )

    after_create :mark_owner_as_signed

    private

    def mark_owner_as_signed
      return unless owner.is_a? Investor

      owner.sign!
    end
  end
end

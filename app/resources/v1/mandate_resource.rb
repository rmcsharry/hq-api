# frozen_string_literal: true

module V1
  # Defines the Mandate resource for the API
  class MandateResource < JSONAPI::Resource
    attributes(
      :category,
      :comment,
      :datev_creditor_id,
      :datev_debitor_id,
      :owner_name,
      :psplus_id,
      :state,
      :valid_from,
      :valid_to
    )

    has_many :mandate_members
    has_many :mandate_groups
    has_many :documents
    has_many :bank_accounts
    has_many :owners, class_name: 'MandateMember'
    has_one :primary_consultant, class_name: 'Contact'
    has_one :secondary_consultant, class_name: 'Contact'
    has_one :assistant, class_name: 'Contact'
    has_one :bookkeeper, class_name: 'Contact'

    class << self
      def resource_for(model_record, context)
        resource_klass = resource_klass_for_model(model_record)
        resource_klass.new(model_record.decorate, context)
      end
    end
  end
end

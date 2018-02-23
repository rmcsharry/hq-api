module V1
  # Defines the Mandate resource for the API
  class MandateResource < JSONAPI::Resource
    attributes(
      :state, :category, :comment, :valid_from, :valid_to, :datev_creditor_id, :datev_debitor_id, :psplus_id
    )

    has_many :mandate_members
    has_many :mandate_groups
    has_one :primary_consultant, class_name: 'Contact'
    has_one :secondary_consultant, class_name: 'Contact'
    has_one :assistant, class_name: 'Contact'
    has_one :bookkeeper, class_name: 'Contact'
  end
end

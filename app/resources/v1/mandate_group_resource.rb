# frozen_string_literal: true

module V1
  # Defines the Mandate Group resource for the API
  class MandateGroupResource < JSONAPI::Resource
    attributes(:name, :group_type, :updated_at)

    has_many :mandates
    has_many :user_groups

    filters(
      :group_type
    )

    filter :name, apply: lambda { |records, value, _options|
      records.where('mandate_groups.name ILIKE ?', "%#{value[0]}%")
    }
  end
end

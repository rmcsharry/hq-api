# frozen_string_literal: true

module V1
  # Defines the Family resource for the API
  class FamilyResource < JSONAPI::Resource
    model_name 'MandateGroup'

    attributes(:name, :mandate_count)

    has_many :mandates
    has_many :user_groups

    filter :name, apply: lambda { |records, value, _options|
      records.where('mandate_groups.name ILIKE ?', "%#{value[0]}%")
    }

    class << self
      def records(_options)
        super.families.with_mandate_count
      end
    end
  end
end

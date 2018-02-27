module V1
  # Defines the Mandate Group resource for the API
  class MandateGroupResource < JSONAPI::Resource
    attributes(:name, :group_type)

    has_many :mandates
    has_many :user_groups
  end
end
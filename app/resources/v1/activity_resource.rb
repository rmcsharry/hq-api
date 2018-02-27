module V1
  # Defines the Activity resource for the API
  class ActivityResource < JSONAPI::Resource
    attributes(:started_at, :ended_at, :title, :description)

    has_many :mandates
    has_many :contacts
    has_many :documents
  end
end

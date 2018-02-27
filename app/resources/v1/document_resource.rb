module V1
  # Defines the Document resource for the API
  class DocumentResource < JSONAPI::Resource
    attributes(:name, :category, :valid_from, :valid_to)

    has_one :owner, polymorphic: true
  end
end

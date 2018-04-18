module V1
  # Defines the Document resource for the API
  class DocumentResource < JSONAPI::Resource
    attributes(
      :category,
      :created_at,
      :name,
      :valid_from,
      :valid_to
    )

    has_one :owner, polymorphic: true

    filter :owner_id
  end
end

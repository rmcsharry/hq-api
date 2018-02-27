module V1
  # Defines the Contact Detail resource for the API
  class ContactDetailResource < JSONAPI::Resource
    attributes :category, :value, :primary

    has_one :contact
  end
end

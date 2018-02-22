module V1
  # Defines the Address resource for the API
  class AddressResource < JSONAPI::Resource
    attributes :category, :street_and_number, :addition, :postal_code, :city, :country

    has_one :contact

    filter :contact_id
  end
end

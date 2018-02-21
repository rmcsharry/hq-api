module V1
  # Defines the Address resource for the API
  class AddressResource < JSONAPI::Resource
    attributes :street, :house_number, :postal_code, :city, :country, :addition

    has_one :contact

    filter :contact_id
  end
end

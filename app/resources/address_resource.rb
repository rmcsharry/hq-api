class AddressResource < JSONAPI::Resource
  attributes :street, :house_number, :postal_code, :city, :country, :addition
  has_one :contact

  filter :contact
end

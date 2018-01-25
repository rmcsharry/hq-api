class ContactResource < JSONAPI::Resource
  attributes :first_name, :last_name, :email
  has_many :addresses
end

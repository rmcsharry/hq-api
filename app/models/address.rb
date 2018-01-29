# Defines the Address model
class Address < ApplicationRecord
  belongs_to :contact
end

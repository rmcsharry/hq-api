# == Schema Information
#
# Table name: addresses
#
#  id                :uuid             not null, primary key
#  contact_id        :uuid
#  postal_code       :string
#  city              :string
#  country           :string
#  addition          :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  category          :string
#  street_and_number :string
#

# Defines the Address model
class Address < ApplicationRecord
  extend Enumerize

  COUNTRIES = Carmen::Country.all.map(&:code)
  CATEGORIES = %i[home work vacation].freeze

  belongs_to :contact
  has_one(
    :legal_address_contact,
    class_name: 'Contact', inverse_of: :legal_address, foreign_key: :legal_address_id, dependent: :nullify
  )
  has_one(
    :primary_contact_address_contact,
    class_name: 'Contact', inverse_of: :primary_contact_address,
    foreign_key: :primary_contact_address_id, dependent: :nullify
  )

  validates :category, presence: true
  validates :street_and_number, presence: true
  validates :postal_code, presence: true
  validates :city, presence: true
  validates :country, presence: true

  enumerize :country, in: COUNTRIES
  enumerize :category, in: CATEGORIES
end

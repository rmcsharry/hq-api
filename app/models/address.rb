# == Schema Information
#
# Table name: addresses
#
#  id           :uuid             not null, primary key
#  contact_id   :integer
#  street       :string
#  house_number :string
#  postal_code  :string
#  city         :string
#  country      :string
#  addition     :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

# Defines the Address model
class Address < ApplicationRecord
  extend Enumerize

  belongs_to :contact

  COUNTRIES = Carmen::Country.all.map(&:code)

  enumerize :country, in: COUNTRIES
end

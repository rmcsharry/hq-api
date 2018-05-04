# frozen_string_literal: true

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
#  state             :string
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

  validates :category, presence: true
  validates :street_and_number, presence: true
  validates :postal_code, presence: true
  validates :city, presence: true
  validates :country, presence: true

  enumerize :country, in: COUNTRIES
  enumerize :category, in: CATEGORIES
end

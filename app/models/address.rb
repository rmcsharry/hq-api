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

  attr_accessor :primary_contact_address, :legal_address

  belongs_to :contact, inverse_of: :addresses

  has_paper_trail(
    meta: {
      parent_item_id: :contact_id,
      parent_item_type: 'Contact'
    },
    skip: SKIPPED_ATTRIBUTES
  )

  validates :category, presence: true
  validates :street_and_number, presence: true
  validates :postal_code, presence: true
  validates :city, presence: true
  validates :country, presence: true

  enumerize :country, in: COUNTRIES
  enumerize :category, in: CATEGORIES

  before_save :set_primary_contact_address
  before_save :set_legal_address

  before_destroy :check_primary_contact_address
  before_destroy :check_legal_address

  def set_primary_contact_address
    return unless primary_contact_address
    contact.primary_contact_address = self
    contact.save!
  end

  def set_legal_address
    return unless legal_address
    contact.legal_address = self
    contact.save!
  end

  def check_primary_contact_address
    return unless contact.primary_contact_address == self
    errors[:base] << 'Cannot delete address while it is the primary contact address.'
    throw :abort
  end

  def check_legal_address
    return unless contact.legal_address == self
    errors[:base] << 'Cannot delete address while it is the legal address.'
    throw :abort
  end
end

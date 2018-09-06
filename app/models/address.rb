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
  has_one(
    :contact_primary_contact_address, class_name: 'Contact', foreign_key: :primary_contact_address_id,
                                      inverse_of: :primary_contact_address, dependent: :nullify
  )
  has_one(
    :contact_legal_address, class_name: 'Contact', foreign_key: :legal_address_id, inverse_of: :legal_address,
                            dependent: :nullify
  )

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

  after_initialize :set_defaults

  before_save :set_primary_contact_address
  before_save :set_legal_address

  before_destroy :check_primary_contact_address
  before_destroy :check_legal_address

  def to_s
    [
      street_and_number,
      addition,
      postal_code,
      city,
      country
    ].compact.join(', ')
  end

  private

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
    return if contact.primary_contact_address != self || destroyed_by_association
    errors[:base] << 'Cannot delete address while it is the primary contact address.'
    throw :abort
  end

  def check_legal_address
    return if contact.legal_address != self || destroyed_by_association
    errors[:base] << 'Cannot delete address while it is the legal address.'
    throw :abort
  end

  def set_defaults
    self.category = 'home' unless category
  end
end

# frozen_string_literal: true

# == Schema Information
#
# Table name: addresses
#
#  id                :uuid             not null, primary key
#  owner_id          :uuid             not null
#  postal_code       :string
#  city              :string
#  country           :string
#  addition          :string
#  state             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  category          :string
#  street_and_number :string
#  owner_type        :string           not null
#
# Indexes
#
#  index_addresses_on_owner_type_and_owner_id  (owner_type,owner_id)
#

# Defines the Address model
class Address < ApplicationRecord
  extend Enumerize

  COUNTRIES = Carmen::Country.all.map(&:code)
  CATEGORIES = %i[home work vacation].freeze

  attr_accessor :primary_contact_address, :legal_address

  belongs_to :owner, polymorphic: true, inverse_of: :addresses

  has_paper_trail(
    meta: {
      parent_item_id: :owner_id,
      parent_item_type: :owner_type
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
  before_save :save_owner_if_not_persisted

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
    owner.primary_contact_address = self
    owner.save!
  end

  def set_legal_address
    return unless legal_address
    owner.legal_address = self
    owner.save!
  end

  def save_owner_if_not_persisted
    return if owner.persisted?
    owner.save!
    self.owner = owner.reload
  end

  def check_primary_contact_address
    return if owner.primary_contact_address != self || destroyed_by_association
    errors[:base] << 'Cannot delete address while it is the primary contact address.'
    throw :abort
  end

  def check_legal_address
    return if owner.legal_address != self || destroyed_by_association
    errors[:base] << 'Cannot delete address while it is the legal address.'
    throw :abort
  end

  def set_defaults
    self.category = 'home' unless category
  end
end

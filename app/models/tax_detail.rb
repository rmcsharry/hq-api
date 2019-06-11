# frozen_string_literal: true

# == Schema Information
#
# Table name: tax_details
#
#  common_reporting_standard :boolean          default(FALSE), not null
#  contact_id                :uuid
#  created_at                :datetime         not null
#  de_church_tax             :boolean          default(FALSE), not null
#  de_health_insurance       :boolean          default(FALSE), not null
#  de_retirement_insurance   :boolean          default(FALSE), not null
#  de_tax_id                 :string
#  de_tax_number             :string
#  de_tax_office             :string
#  de_unemployment_insurance :boolean          default(FALSE), not null
#  eu_vat_number             :string
#  id                        :uuid             not null, primary key
#  legal_entity_identifier   :string
#  transparency_register     :boolean          default(FALSE), not null
#  updated_at                :datetime         not null
#  us_fatca_status           :string
#  us_tax_form               :string
#  us_tax_number             :string
#
# Indexes
#
#  index_tax_details_on_contact_id  (contact_id)
#
# Foreign Keys
#
#  fk_rails_...  (contact_id => contacts.id)
#

# Defines the Tax Details of a Contact
class TaxDetail < ApplicationRecord
  extend Enumerize
  strip_attributes only: %i[
    de_tax_id de_tax_number de_tax_office eu_vat_number
    legal_entity_identifier us_fatca_status us_tax_form us_tax_number
  ], collapse_spaces: true

  US_TAX_FORMS = %i[none w_8ben w_8ben_e w_8imy w_8eci w_8exp w_9].freeze
  US_FATCA_STATUSES = %i[
    none participation_ffi reporting_ffi nonreporting_ffi owner_documented_ffi active_nffe passive_nffe
  ].freeze

  belongs_to :contact
  has_many :foreign_tax_numbers, dependent: :destroy

  has_paper_trail(
    meta: {
      parent_item_id: :contact_id,
      parent_item_type: 'Contact'
    },
    skip: SKIPPED_ATTRIBUTES
  )

  validates :contact_id, uniqueness: { case_sensitive: false }
  validates :de_tax_number, de_tax_number: true, if: -> { de_tax_number.present? }
  validates :de_tax_id, de_tax_id: true, if: -> { de_tax_id.present? }
  validates :de_retirement_insurance, absence: true, if: -> { belongs_to_organization? }
  validates :de_retirement_insurance, inclusion: { in: [true, false] }
  validates :de_unemployment_insurance, absence: true, if: -> { belongs_to_organization? }
  validates :de_unemployment_insurance, inclusion: { in: [true, false] }
  validates :de_health_insurance, absence: true, if: -> { belongs_to_organization? }
  validates :de_health_insurance, inclusion: { in: [true, false] }
  validates :de_church_tax, absence: true, if: -> { belongs_to_organization? }
  validates :de_church_tax, inclusion: { in: [true, false] }
  validates :common_reporting_standard, inclusion: { in: [true, false] }
  validates :eu_vat_number, absence: true, unless: -> { belongs_to_organization? }
  validates :eu_vat_number, valvat: true, if: -> { belongs_to_organization? && eu_vat_number.present? }
  validates :legal_entity_identifier, absence: true, unless: -> { belongs_to_organization? }
  validates :transparency_register, absence: true, unless: -> { belongs_to_organization? }

  enumerize :us_tax_form, in: US_TAX_FORMS, scope: true
  enumerize :us_fatca_status, in: US_FATCA_STATUSES, scope: true

  def belongs_to_organization?
    contact.present? && contact.organization?
  end
end

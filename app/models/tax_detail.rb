# == Schema Information
#
# Table name: tax_details
#
#  id                        :uuid             not null, primary key
#  de_tax_number             :string
#  de_tax_id                 :string
#  de_tax_office             :string
#  de_retirement_insurance   :boolean          default(FALSE), not null
#  de_unemployment_insurance :boolean          default(FALSE), not null
#  de_health_insurance       :boolean          default(FALSE), not null
#  de_church_tax             :boolean          default(FALSE), not null
#  us_tax_number             :string
#  us_tax_form               :string
#  us_fatca_status           :string
#  common_reporting_standard :boolean          default(FALSE), not null
#  eu_vat_number             :string
#  legal_entity_identifier   :string
#  transparency_register     :boolean          default(FALSE), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  contact_id                :uuid
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

  belongs_to :contact
  has_many :foreign_tax_numbers, dependent: :destroy

  validates :contact_id, uniqueness: { case_sensitive: false }
  validates :de_tax_number, de_tax_number: true
  validates :de_tax_id, de_tax_id: true
  validates :de_retirement_insurance, presence: true, unless: -> { belongs_to_organization? }
  validates :de_unemployment_insurance, presence: true, unless: -> { belongs_to_organization? }
  validates :de_health_insurance, presence: true, unless: -> { belongs_to_organization? }
  validates :de_church_tax, presence: true, unless: -> { belongs_to_organization? }
  validates :common_reporting_standard, presence: true
  validates :eu_vat_number, absence: true, unless: -> { belongs_to_organization? }
  validates :eu_vat_number, valvat: true
  validates :legal_entity_identifier, absence: true, unless: -> { belongs_to_organization? }
  validates :transparency_register, absence: true, unless: -> { belongs_to_organization? }

  enumerize :us_tax_form, in: %i[w_8ben w_8ben_e w_8imy w_8eci w_8exp], scope: true
  enumerize(
    :us_fatca_status,
    in: %i[participation_ffi reporting_ffi nonreporting_ffi owner_documented_ffi active_nffe passive_nffe],
    scope: true
  )

  def belongs_to_organization?
    contact.present? && contact.organization?
  end
end

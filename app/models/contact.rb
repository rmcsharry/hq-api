# == Schema Information
#
# Table name: contacts
#
#  id                         :uuid             not null, primary key
#  first_name                 :string
#  last_name                  :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  type                       :string
#  comment                    :text
#  gender                     :string
#  nobility_title             :string
#  professional_title         :string
#  maiden_name                :string
#  date_of_birth              :date
#  date_of_death              :date
#  nationality                :string
#  organization_name          :string
#  organization_type          :string
#  organization_category      :string
#  organization_industry      :string
#  commercial_register_number :string
#  commercial_register_office :string
#  legal_address_id           :uuid
#  primary_contact_address_id :uuid
#
# Indexes
#
#  index_contacts_on_legal_address_id            (legal_address_id)
#  index_contacts_on_primary_contact_address_id  (primary_contact_address_id)
#
# Foreign Keys
#
#  fk_rails_...  (legal_address_id => addresses.id)
#  fk_rails_...  (primary_contact_address_id => addresses.id)
#

# Defines the Contact model
class Contact < ApplicationRecord
  belongs_to :legal_address, class_name: 'Address', optional: true, inverse_of: :legal_address_contact
  belongs_to(
    :primary_contact_address, class_name: 'Address', optional: true, inverse_of: :primary_contact_address_contact
  )
  has_many :addresses, dependent: :destroy
  has_many :primary_consultant_mandates, class_name: 'Mandate', inverse_of: :primary_consultant, dependent: :nullify
  has_many :secondary_consultant_mandates, class_name: 'Mandate', inverse_of: :secondary_consultant, dependent: :nullify
  has_many :assistant_mandates, class_name: 'Mandate', inverse_of: :assistant, dependent: :nullify
  has_many :bookkeeper_mandates, class_name: 'Mandate', inverse_of: :bookkeeper, dependent: :nullify
  has_many :mandate_members, dependent: :destroy
  has_many :mandates, through: :mandate_members
  has_many :contact_details, dependent: :destroy
  has_many :documents, as: :owner, inverse_of: :owner, dependent: :destroy
  has_one :compliance_detail, dependent: :destroy
  has_one :tax_detail, dependent: :destroy
  has_and_belongs_to_many :activities

  # Returns boolean to define whether the contact is an organization or not
  # @return [Boolean] generaly false, overwritte in subclass
  def organization?
    false
  end
end

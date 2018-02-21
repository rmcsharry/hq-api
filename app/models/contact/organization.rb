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

class Contact
  # Defines the Contact model for organizations
  class Organization < Contact
    extend Enumerize

    validates :organization_name, presence: true
    validates :organization_type, presence: true
    validates :commercial_register_office, presence: true, if: :commercial_register_number
    validates :commercial_register_number, presence: true, if: :commercial_register_office

    enumerize :organization_type, in: %i[gmbh ag foreign_ag lp gmbh_co_kg gbr limited llc vvag ev], scope: true

    # Returns boolean to define whether the contact is an organization or not
    # @return [Boolean] if contact is organization
    def organization?
      true
    end
  end
end
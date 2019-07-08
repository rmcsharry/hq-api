# frozen_string_literal: true

# == Schema Information
#
# Table name: contacts
#
#  comment                       :text
#  commercial_register_number    :string
#  commercial_register_office    :string
#  created_at                    :datetime         not null
#  data_integrity_missing_fields :string           default([]), is an Array
#  data_integrity_score          :decimal(5, 4)    default(0.0)
#  date_of_birth                 :date
#  date_of_death                 :date
#  first_name                    :string
#  gender                        :string
#  id                            :uuid             not null, primary key
#  import_id                     :integer
#  last_name                     :string
#  legal_address_id              :uuid
#  maiden_name                   :string
#  nationality                   :string
#  nobility_title                :string
#  organization_category         :string
#  organization_industry         :string
#  organization_name             :string
#  organization_type             :string
#  place_of_birth                :string
#  primary_contact_address_id    :uuid
#  professional_title            :string
#  type                          :string
#  updated_at                    :datetime         not null
#
# Indexes
#
#  index_contacts_on_data_integrity_score        (data_integrity_score)
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
    include WeightRulesOrganization
    include Scoreable

    def self.policy_class
      ContactPolicy
    end

    ORGANIZATION_TYPES = %i[
      ag church eg ev foreign_ag foreign_gmbh foundation fund gbr gmbh gmbh_co_kg kg limited
      llc lp other partg statutory_corporation statutory_institution trust vvag
    ].freeze

    has_many :bank_accounts, foreign_key: :bank_id, dependent: :nullify, inverse_of: :bank
    has_many :contacts, through: :contact_members

    validates :organization_name, presence: true
    validates :organization_type, presence: true
    validates :commercial_register_office, presence: true, if: :commercial_register_number
    validates :commercial_register_number, presence: true, if: :commercial_register_office

    enumerize :organization_type, in: ORGANIZATION_TYPES, scope: true

    # Returns boolean to define whether the contact is an organization or not
    # @return [Boolean] if contact is organization
    def organization?
      true
    end

    def to_s
      organization_name
    end
  end
end

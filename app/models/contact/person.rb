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
  # Defines the Contact model for natural persons
  class Person < Contact
    extend Enumerize

    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :gender, presence: true
    validates :date_of_birth, presence: true, if: :date_of_death

    validate :date_of_death_greater_or_equal_date_of_birth

    enumerize :gender, in: %i[male female], scope: true
    enumerize :nobility_title, in: %i[baron baroness count countess], scope: true
    enumerize :professional_title, in: %i[doctor professor professor_doctor], scope: true
    enumerize :nationality, in: Address::COUNTRIES

    def date_of_death_greater_or_equal_date_of_birth
      return if date_of_death.blank? || date_of_death >= date_of_birth
      errors.add(:date_of_death, "can't be before the date of birth")
    end
  end
end

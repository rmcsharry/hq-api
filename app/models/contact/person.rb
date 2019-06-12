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
#  data_integrity_score          :decimal(4, 3)    default(0.0)
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
    def self.policy_class
      ContactPolicy
    end

    GENDERS = %i[male female].freeze
    NOBILITY_TITLES = %i[baron baroness count countess prince princess].freeze
    PROFESSIONAL_TITLES = %i[
      assessor_jur_dipl
      betriebswirt_vwa
      dipl
      dipl_betriebsw
      dipl_finw
      dipl_inf
      dipl_ing
      dipl_ing_fh
      dipl_kffr
      dipl_kfm
      dipl_math_oec
      dipl_oec
      dipl_volksw
      dipl_wirtsch_ing
      dr
      dr_dipl_kfm
      dr_dipl_oec
      dr_dipl_volksw
      dr_dr
      dr_dr_hc
      dr_hc
      dr_iur
      dr_med_dr_rer_nat
      dr_oec
      dr_phil
      dr_rer_nat_hc
      dr_rer_oec
      dr_rer_pol
      dr_sc_techn
      dr_ing
      dr_ing_eh
      ing
      mag
      prof
      prof_dipl_ing
      prof_dr
      prof_dr_hc_mult
      prod_dr_jur
      prof_dr_ing_eh
      prof_dr_ing_eh_dipl_kfm
      prof_hc_dipl_ing
      senator_assoz_prof
    ].freeze

    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :gender, presence: true
    validates :date_of_birth, presence: true, if: :date_of_death

    validate :date_of_death_greater_or_equal_date_of_birth

    enumerize :gender, in: GENDERS, scope: true
    enumerize :nobility_title, in: NOBILITY_TITLES, scope: true
    enumerize :professional_title, in: PROFESSIONAL_TITLES, scope: true
    enumerize :nationality, in: Address::COUNTRIES

    def to_s
      [
        gender_text,
        professional_title_text,
        first_name,
        nobility_title_text,
        last_name,
        maiden_name ? "(#{maiden_name})" : nil
      ].compact.join(' ')
    end

    private

    # Validates if date_of_birth is before or on the same date as date_of_death if date_of_death is set
    # @return [void]
    def date_of_death_greater_or_equal_date_of_birth
      return if date_of_death.blank? || date_of_death >= date_of_birth

      errors.add(:date_of_death, "can't be before the date of birth")
    end
  end
end

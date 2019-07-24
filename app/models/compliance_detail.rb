# frozen_string_literal: true

# == Schema Information
#
# Table name: compliance_details
#
#  contact_id          :uuid
#  created_at          :datetime         not null
#  id                  :uuid             not null, primary key
#  kagb_classification :string
#  occupation_role     :string
#  occupation_title    :string
#  politically_exposed :boolean          default(FALSE), not null
#  retirement_age      :integer
#  updated_at          :datetime         not null
#  wphg_classification :string
#
# Indexes
#
#  index_compliance_details_on_contact_id  (contact_id)
#
# Foreign Keys
#
#  fk_rails_...  (contact_id => contacts.id)
#

# Defines the Compliance Details of a Contact
class ComplianceDetail < ApplicationRecord
  extend Enumerize
  include Scoreable::ComplianceDetail
  strip_attributes only: :occupation_title, collapse_spaces: true

  WPHG_CLASSIFICATIONS = %i[none private born_professional chosen_professional suitable_counterparty].freeze
  KAGB_CLASSIFICATIONS = %i[none private semi_professional professional].freeze
  OCCUPATION_ROLES = %i[
    worker technician foreman employee qualified_employee chief_executive managing_director officer retiree
    housewife pupil student apprentice military_or_civil_service unemployed self_employed supervisory_board_member
  ].freeze

  belongs_to :contact

  has_paper_trail(
    meta: {
      parent_item_id: :contact_id,
      parent_item_type: 'Contact'
    },
    skip: SKIPPED_ATTRIBUTES
  )

  validates :contact_id, uniqueness: { case_sensitive: false }
  validates :wphg_classification, presence: true
  validates :kagb_classification, presence: true

  enumerize :wphg_classification, in: WPHG_CLASSIFICATIONS, scope: true
  enumerize :kagb_classification, in: KAGB_CLASSIFICATIONS, scope: true
  enumerize :occupation_role, in: OCCUPATION_ROLES, scope: true
end

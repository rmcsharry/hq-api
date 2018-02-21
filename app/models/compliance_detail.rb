# == Schema Information
#
# Table name: compliance_details
#
#  id                  :uuid             not null, primary key
#  wphg_classification :string
#  kagb_classification :string
#  politically_exposed :boolean          default(FALSE), not null
#  occupation_role     :string
#  occupation_title    :string
#  retirement_age      :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  contact_id          :uuid
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

  belongs_to :contact

  validates :contact, presence: true
  validates :wphg_classification, presence: true
  validates :kagb_classification, presence: true

  enumerize(
    :wphg_classification, in: %i[none private born_professional chosen_professional suitable_counterparty], scope: true
  )
  enumerize(
    :kagb_classification, in: %i[none private semi_professional professional], scope: true
  )
end
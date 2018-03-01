# == Schema Information
#
# Table name: contact_details
#
#  id         :uuid             not null, primary key
#  type       :string
#  category   :string
#  value      :string
#  primary    :boolean          default(FALSE), not null
#  contact_id :uuid
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_contact_details_on_contact_id  (contact_id)
#
# Foreign Keys
#
#  fk_rails_...  (contact_id => contacts.id)
#

# Defines the Contact Details of a Contact
class ContactDetail < ApplicationRecord
  extend Enumerize

  CATEGORIES = %i[home work vacation].freeze

  belongs_to :contact

  validates :type, presence: true
  validates :category, presence: true
  validates :value, presence: true

  enumerize :category, in: CATEGORIES, scope: true
end

# frozen_string_literal: true

# == Schema Information
#
# Table name: contact_details
#
#  category   :string
#  contact_id :uuid
#  created_at :datetime         not null
#  id         :uuid             not null, primary key
#  primary    :boolean          default(FALSE), not null
#  type       :string
#  updated_at :datetime         not null
#  value      :string
#
# Indexes
#
#  index_contact_details_on_contact_id  (contact_id)
#
# Foreign Keys
#
#  fk_rails_...  (contact_id => contacts.id)
#

class ContactDetail
  # Defines the Email of a Contact
  class Email < ContactDetail
    def self.policy_class
      ContactDetailPolicy
    end

    validates :value, email: { strict_mode: true }

    before_validation :normalize_email

    private

    def normalize_email
      self.value = value.downcase
    end
  end
end

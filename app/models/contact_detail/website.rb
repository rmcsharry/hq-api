# frozen_string_literal: true

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

class ContactDetail
  # Defines the Website of a Contact
  class Website < ContactDetail
    def self.policy_class
      ContactDetailPolicy
    end

    validates :value, url: { no_local: true }

    before_validation :normalize_url

    private

    def normalize_url
      self.value = value.downcase
      self.value = "https://#{value}" unless value.starts_with?('http://') || value.starts_with?('https://')
    end
  end
end

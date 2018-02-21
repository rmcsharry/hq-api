# == Schema Information
#
# Table name: mandates
#
#  id                      :uuid             not null, primary key
#  state                   :string
#  category                :string
#  comment                 :text
#  valid_from              :string
#  valid_to                :string
#  datev_creditor_id       :string
#  datev_debitor_id        :string
#  psplus_id               :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  primary_consultant_id   :uuid
#  secondary_consultant_id :uuid
#  assistant_id            :uuid
#  bookkeeper_id           :uuid
#
# Indexes
#
#  index_mandates_on_assistant_id             (assistant_id)
#  index_mandates_on_bookkeeper_id            (bookkeeper_id)
#  index_mandates_on_primary_consultant_id    (primary_consultant_id)
#  index_mandates_on_secondary_consultant_id  (secondary_consultant_id)
#
# Foreign Keys
#
#  fk_rails_...  (assistant_id => contacts.id)
#  fk_rails_...  (bookkeeper_id => contacts.id)
#  fk_rails_...  (primary_consultant_id => contacts.id)
#  fk_rails_...  (secondary_consultant_id => contacts.id)
#

# Defines the Mandate model
class Mandate < ApplicationRecord
  belongs_to :primary_consultant, class_name: 'Contact', optional: true
  belongs_to :secondary_consultant, class_name: 'Contact', optional: true
  belongs_to :assistant, class_name: 'Contact', optional: true
  belongs_to :bookkeeper, class_name: 'Contact', optional: true
end

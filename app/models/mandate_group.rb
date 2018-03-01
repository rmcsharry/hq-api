# == Schema Information
#
# Table name: mandate_groups
#
#  id         :uuid             not null, primary key
#  name       :string
#  group_type :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# Defines the Mandate Group
class MandateGroup < ApplicationRecord
  extend Enumerize

  GROUP_TYPES = %i[family organization].freeze

  has_and_belongs_to_many :mandates
  has_and_belongs_to_many :user_groups

  validates :name, presence: true
  validates :group_type, presence: true

  enumerize :group_type, in: GROUP_TYPES, scope: true
end

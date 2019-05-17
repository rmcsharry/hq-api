# frozen_string_literal: true

# == Schema Information
#
# Table name: mandate_groups
#
#  comment    :text
#  created_at :datetime         not null
#  group_type :string
#  id         :uuid             not null, primary key
#  name       :string
#  updated_at :datetime         not null
#

# Defines the Mandate Group
class MandateGroup < ApplicationRecord
  extend Enumerize

  GROUP_TYPES = %i[family organization].freeze

  has_many :mandate_groups_mandates, dependent: :destroy
  has_and_belongs_to_many :mandates, -> { distinct }
  has_and_belongs_to_many :user_groups, -> { distinct }

  has_paper_trail(skip: SKIPPED_ATTRIBUTES)

  validates :name, presence: true
  validates :group_type, presence: true

  enumerize :group_type, in: GROUP_TYPES, scope: true

  scope :families, -> { where(group_type: 'family') }
  scope :organizations, -> { where(group_type: 'organization') }
end

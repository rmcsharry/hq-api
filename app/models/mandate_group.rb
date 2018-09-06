# frozen_string_literal: true

# == Schema Information
#
# Table name: mandate_groups
#
#  id         :uuid             not null, primary key
#  name       :string
#  group_type :string
#  comment    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# Defines the Mandate Group
class MandateGroup < ApplicationRecord
  extend Enumerize

  GROUP_TYPES = %i[family organization].freeze

  has_many :mandate_groups_mandates, dependent: :destroy
  has_and_belongs_to_many :mandates, uniq: true
  has_and_belongs_to_many :user_groups, uniq: true

  has_paper_trail(skip: SKIPPED_ATTRIBUTES)

  validates :name, presence: true
  validates :group_type, presence: true

  enumerize :group_type, in: GROUP_TYPES, scope: true

  scope :families, -> { where(group_type: 'family') }
  scope :organizations, -> { where(group_type: 'organization') }
end

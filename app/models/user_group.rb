# == Schema Information
#
# Table name: user_groups
#
#  id         :uuid             not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  comment    :text
#

# Defines the User Group
class UserGroup < ApplicationRecord
  has_and_belongs_to_many :mandate_groups
  has_and_belongs_to_many :users

  validates :name, presence: true
end

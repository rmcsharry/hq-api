# frozen_string_literal: true

# == Schema Information
#
# Table name: lists
#
#  aasm_state :string           default("active"), not null
#  comment    :text
#  created_at :datetime         not null
#  id         :uuid             not null, primary key
#  name       :string
#  updated_at :datetime         not null
#  user_id    :uuid             not null
#
# Indexes
#
#  index_lists_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :list do
    user
    name { Faker::Lorem.words.join(' ').titleize }
  end
end

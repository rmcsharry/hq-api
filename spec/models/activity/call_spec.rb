# frozen_string_literal: true

# == Schema Information
#
# Table name: activities
#
#  created_at  :datetime         not null
#  creator_id  :uuid
#  description :text
#  ended_at    :datetime
#  ews_id      :string
#  id          :uuid             not null, primary key
#  started_at  :datetime
#  title       :string
#  type        :string
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_activities_on_creator_id  (creator_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#

require 'rails_helper'

RSpec.describe Activity::Call, type: :model do
  describe '#started_at' do
    it { is_expected.to validate_presence_of(:started_at) }
  end
end

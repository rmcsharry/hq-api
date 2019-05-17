# frozen_string_literal: true

# == Schema Information
#
# Table name: task_comments
#
#  comment    :text
#  created_at :datetime         not null
#  id         :uuid             not null, primary key
#  task_id    :uuid             not null
#  updated_at :datetime         not null
#  user_id    :uuid             not null
#
# Indexes
#
#  index_task_comments_on_task_id  (task_id)
#  index_task_comments_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (task_id => tasks.id)
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

RSpec.describe TaskComment, type: :model do
  it { is_expected.to validate_presence_of(:comment) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_one(:contact) }
  it { is_expected.to belong_to(:task) }
end

# frozen_string_literal: true

# == Schema Information
#
# Table name: tasks
#
#  id                 :uuid             not null, primary key
#  creator_id         :uuid
#  finisher_id        :uuid
#  subject_type       :string
#  subject_id         :uuid
#  linked_object_type :string
#  linked_object_id   :uuid
#  aasm_state         :string           not null
#  description        :string
#  title              :string           not null
#  type               :string           not null
#  finished_at        :datetime
#  due_at             :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_tasks_on_creator_id                               (creator_id)
#  index_tasks_on_finisher_id                              (finisher_id)
#  index_tasks_on_linked_object_type_and_linked_object_id  (linked_object_type,linked_object_id)
#  index_tasks_on_subject_type_and_subject_id              (subject_type,subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (finisher_id => users.id)
#

require 'rails_helper'

RSpec.describe Task::Simple, type: :model do
  subject { build(:task_simple) }

  it { is_expected.to validate_presence_of(:creator) }
end

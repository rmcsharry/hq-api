# frozen_string_literal: true

# == Schema Information
#
# Table name: tasks
#
#  id           :uuid             not null, primary key
#  creator_id   :uuid
#  finisher_id  :uuid
#  aasm_state   :string           not null
#  description  :string
#  title        :string           not null
#  finished_at  :datetime
#  due_at       :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  type         :string
#  subject_type :string
#  subject_id   :bigint(8)
#
# Indexes
#
#  index_tasks_on_creator_id                   (creator_id)
#  index_tasks_on_finisher_id                  (finisher_id)
#  index_tasks_on_subject_type_and_subject_id  (subject_type,subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (finisher_id => users.id)
#

FactoryBot.define do
  factory :task, class: Task::Simple do
    title { Faker::Company.catch_phrase }
    creator { create :user }

    trait :finished do
      aasm_state { :finished }
      finisher { create :user }
      finished_at { Faker::Time.between(2.days.ago, Time.zone.now) }
    end

    factory :task_simple, class: Task::Simple do
      creator { create :user }
    end

    factory :contact_birthday_reminder, class: Task::ContactBirthdayReminder do
      subject { create :contact_person }
    end

    factory :document_expiry_reminder, class: Task::DocumentExpiryReminder do
      subject { create :document }
    end
  end
end

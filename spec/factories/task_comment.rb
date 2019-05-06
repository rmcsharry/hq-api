# frozen_string_literal: true

FactoryBot.define do
  factory :task_comment, class: TaskComment do
    transient do
      creator { create :user }
    end

    user { creator }
    comment { Faker::Lorem.sentence }
    task { create :task, creator: creator }
  end
end

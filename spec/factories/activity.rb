# frozen_string_literal: true

FactoryBot.define do
  factory :activity do
    title 'Activity with Mr. X'
    description 'Lorem ipsum'
    creator { create(:user) }

    factory :activity_call, class: Activity::Call do
      started_at { 2.days.ago }
      ended_at { 1.day.ago }
    end

    factory :activity_email, class: Activity::Email do
      started_at { 2.days.ago }
    end

    factory :activity_meeting, class: Activity::Meeting do
      started_at { 2.days.ago }
      ended_at { 1.day.ago }
    end

    factory :activity_note, class: Activity::Note do
    end
  end
end

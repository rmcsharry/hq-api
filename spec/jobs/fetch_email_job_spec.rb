# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FetchEmailJob, type: :job do
  let(:activity) { create :activity_email }
  let(:fixture_file_name) { 'email_with_attachment.eml' }

  before(:all) do
    @queue_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test
  end

  after(:all) do
    ActiveJob::Base.queue_adapter = @queue_adapter
  end

  before(:each) do
    allow_any_instance_of(FetchEmailJob).to receive(:fetch_email) {
      Base64.encode64(File.read(Rails.root.join('spec', 'fixtures', 'emails', fixture_file_name)))
    }
  end

  describe '#perform_later' do
    it 'enqueues the job' do
      FetchEmailJob.perform_later(activity.id, {})
      expect(FetchEmailJob).to have_been_enqueued.exactly(:once)
    end
  end

  describe 'fetching eml file' do
    describe 'without attachments' do
      let(:fixture_file_name) { 'simple_email.eml' }

      it 'attaches the raw .eml file' do
        expect(activity.documents.size).to eq(0)

        FetchEmailJob.perform_now(activity.id, {})

        activity.reload
        expect(activity.documents.size).to eq(1)
        expect(activity.type).to eq('Activity::Email')
      end
    end

    describe 'with one attachment' do
      let(:fixture_file_name) { 'email_with_attachment.eml' }

      it 'attaches .eml file and attachment' do
        expect(activity.documents.size).to eq(0)

        FetchEmailJob.perform_now(activity.id, {})

        activity.reload
        expect(activity.documents.size).to eq(2)
        expect(activity.type).to eq('Activity::Email')
      end
    end

    describe 'phone call without duration' do
      let(:fixture_file_name) { 'email_with_call_without_duration.eml' }

      it 'sets activity type to Activity::Call' do
        FetchEmailJob.perform_now(activity.id, {})
        reloaded_activity = Activity.find activity.id

        expect(reloaded_activity.type).to eq('Activity::Call')
      end

      it 'does not set call duration' do
        FetchEmailJob.perform_now(activity.id, {})
        reloaded_activity = Activity.find activity.id

        expect(reloaded_activity.ended_at).to eq(nil)
      end
    end

    describe 'plain with phone call' do
      let(:fixture_file_name) { 'plain_email_with_call.eml' }

      it 'sets activity type to Activity::Call' do
        FetchEmailJob.perform_now(activity.id, {})
        reloaded_activity = Activity.find activity.id

        expect(reloaded_activity.type).to eq('Activity::Call')
      end

      it 'parses call duration' do
        FetchEmailJob.perform_now(activity.id, {})
        reloaded_activity = Activity.find activity.id

        expected_ended_at = reloaded_activity.started_at + 42.minutes + 7.seconds
        expect(reloaded_activity.ended_at).to eq(expected_ended_at)
      end
    end

    describe 'multipart with phone call' do
      let(:fixture_file_name) { 'email_with_call.eml' }

      it 'sets activity type to Activity::Call' do
        FetchEmailJob.perform_now(activity.id, {})
        reloaded_activity = Activity.find activity.id

        expect(reloaded_activity.type).to eq('Activity::Call')
      end

      it 'parses call duration' do
        FetchEmailJob.perform_now(activity.id, {})
        reloaded_activity = Activity.find activity.id

        expected_ended_at = reloaded_activity.started_at + 1.hour + 1.minute + 1.second
        expect(reloaded_activity.ended_at).to eq(expected_ended_at)
      end
    end

    describe 'with complexly formatted phone call' do
      let(:fixture_file_name) { 'email_with_complex_call.eml' }

      it 'sets activity type to Activity::Call' do
        FetchEmailJob.perform_now(activity.id, {})
        reloaded_activity = Activity.find activity.id

        expect(reloaded_activity.type).to eq('Activity::Call')
      end

      it 'parses call duration' do
        FetchEmailJob.perform_now(activity.id, {})
        reloaded_activity = Activity.find activity.id

        expected_ended_at = reloaded_activity.started_at + 5.minutes + 5.seconds
        expect(reloaded_activity.ended_at).to eq(expected_ended_at)
      end
    end

    describe 'with conference phone call' do
      let(:fixture_file_name) { 'email_with_conference_call.eml' }

      it 'sets activity type to Activity::Call' do
        FetchEmailJob.perform_now(activity.id, {})
        reloaded_activity = Activity.find activity.id

        expect(reloaded_activity.type).to eq('Activity::Call')
      end

      it 'parses call duration' do
        FetchEmailJob.perform_now(activity.id, {})
        reloaded_activity = Activity.find activity.id

        expected_ended_at = reloaded_activity.started_at + 54.minutes + 5.seconds
        expect(reloaded_activity.ended_at).to eq(expected_ended_at)
      end
    end
  end
end

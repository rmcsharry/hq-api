# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SyncNewsletterSubscriberJob, type: :job do
  let(:subscriber) { create :newsletter_subscriber }

  before(:all) do
    @queue_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test
  end

  after(:all) do
    ActiveJob::Base.queue_adapter = @queue_adapter
  end

  describe '#perform_later' do
    it 'enqueues the job' do
      SyncNewsletterSubscriberJob.perform_later(subscriber.id)
      expect(SyncNewsletterSubscriberJob).to have_been_enqueued.exactly(:once)
    end
  end

  describe 'when subscriber is not confirmed' do
    let(:subscriber) { create :newsletter_subscriber, state: :confirmation_sent }

    it 'throws an exception' do
      expect do
        SyncNewsletterSubscriberJob.perform_now(subscriber.id)
      end.to raise_error(Exception)
    end
  end
end

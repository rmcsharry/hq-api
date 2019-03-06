# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ::V1::NewsletterSubscriberResource, type: :resource do
  let(:newsletter_subscriber) { create(:newsletter_subscriber) }
  subject { described_class.new(newsletter_subscriber, {}) }

  it { is_expected.to have_attribute :confirmation_base_url }
  it { is_expected.to have_attribute :confirmation_sent_at }
  it { is_expected.to have_attribute :confirmation_success_url }
  it { is_expected.to have_attribute :confirmed_at }
  it { is_expected.to have_attribute :created_at }
  it { is_expected.to have_attribute :email }
  it { is_expected.to have_attribute :first_name }
  it { is_expected.to have_attribute :gender }
  it { is_expected.to have_attribute :last_name }
  it { is_expected.to have_attribute :mailjet_list_id }
  it { is_expected.to have_attribute :nobility_title }
  it { is_expected.to have_attribute :professional_title }
  it { is_expected.to have_attribute :state }
  it { is_expected.to have_attribute :subscriber_context }
  it { is_expected.to have_attribute :updated_at }

  it { is_expected.to filter(:email) }
  it { is_expected.to filter(:first_name) }
  it { is_expected.to filter(:last_name) }
end

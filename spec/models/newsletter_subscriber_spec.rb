# frozen_string_literal: true

# == Schema Information
#
# Table name: newsletter_subscribers
#
#  aasm_state               :string
#  confirmation_base_url    :string
#  confirmation_sent_at     :datetime
#  confirmation_success_url :string
#  confirmation_token       :string
#  confirmed_at             :datetime
#  created_at               :datetime         not null
#  email                    :string           not null
#  first_name               :string
#  gender                   :string
#  id                       :uuid             not null, primary key
#  last_name                :string
#  mailjet_list_id          :string
#  nobility_title           :string
#  professional_title       :string
#  questionnaire_results    :jsonb
#  subscriber_context       :string           default("hqt"), not null
#  updated_at               :datetime         not null
#

require 'rails_helper'

RSpec.describe NewsletterSubscriber, type: :model do
  subject { build(:newsletter_subscriber) }

  it { is_expected.to enumerize(:nobility_title) }
  it { is_expected.to enumerize(:professional_title) }
  it { is_expected.to enumerize(:gender) }
  it { is_expected.to enumerize(:subscriber_context) }

  describe '#first_name' do
    context 'last_name is present' do
      subject { build(:newsletter_subscriber, last_name: 'Guntersens') }

      it 'validates presence' do
        expect(subject).to validate_presence_of(:first_name)
      end
    end
  end

  describe '#last_name' do
    context 'first_name is present' do
      subject { build(:newsletter_subscriber, first_name: 'Thomy') }

      it 'validates presence' do
        expect(subject).to validate_presence_of(:last_name)
      end
    end
  end

  describe '#mailjet_list_id' do
    it { is_expected.to validate_presence_of(:mailjet_list_id) }
  end

  describe '#confirmation_base_url' do
    it { is_expected.to validate_presence_of(:confirmation_base_url) }
  end

  describe '#confirmation_success_url' do
    it { is_expected.to validate_presence_of(:confirmation_success_url) }
  end

  describe '#email' do
    let(:valid_emails) { ['test@test.de', 'test@test.co.uk', 'test123-abc.abc@test.de', 'test+test@test.de'] }
    let(:invalid_emails) { ['test test@test.de', 'test', 'test@test', '@test.co.uk', 'test\test@test.de'] }

    it { is_expected.to validate_presence_of(:email) }

    it 'validates email format' do
      expect(subject).to allow_values(*valid_emails).for(:email)
      expect(subject).not_to allow_values(*invalid_emails).for(:email)
    end

    it 'downcases email before validation' do
      subject.email = 'TesT@teSt.DE '
      subject.valid?
      expect(subject.email).to eq 'test@test.de'
    end
  end
end

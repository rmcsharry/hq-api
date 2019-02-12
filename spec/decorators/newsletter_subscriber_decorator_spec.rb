# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewsletterSubscriberDecorator do
  describe 'without titles' do
    subject { build(:newsletter_subscriber, gender: 'male', first_name: 'Max', last_name: 'Mustermann').decorate }

    it 'responds with the full name' do
      expect(subject.name).to eq 'Max Mustermann'
      expect(subject.name_list).to eq 'Mustermann, Max'
      expect(subject.formal_salutation).to eq 'Sehr geehrter Herr Mustermann'
    end
  end

  describe 'with full details' do
    subject { build(:newsletter_subscriber, :with_full_details).decorate }

    it 'responds with the full name and titles' do
      expect(subject.name).to eq 'Thomas Guntersen'
      expect(subject.name_list).to eq 'Guntersen, Thomas'
      expect(subject.formal_salutation).to eq 'Sehr geehrter Herr Prof. Dr. Freiherr Guntersen'
    end
  end

  describe 'without a name' do
    subject { build(:newsletter_subscriber).decorate }

    it 'responds with the full name and titles' do
      expect(subject.name).to eq ''
      expect(subject.name_list).to eq ', '
      expect(subject.formal_salutation).to eq 'Sehr geehrte Damen und Herren'
    end
  end
end

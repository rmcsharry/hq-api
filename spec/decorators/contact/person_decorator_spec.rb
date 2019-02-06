# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contact::PersonDecorator do
  describe '#name' do
    subject { build(:contact_organization, organization_name: 'HQ Trust GmbH').decorate }
    it 'responds with the full name' do
      expect(subject.name).to eq 'HQ Trust GmbH'
    end
  end

  describe '#next_birthday' do
    let!(:person) { create(:contact_person, date_of_birth: Time.zone.local(1990, 1, 10)).decorate }

    it 'doesn\'t break if person has no date_of_birth set' do
      person.date_of_birth = nil
      expect(person.next_birthday).to be_nil
    end

    it 'works when next birthday happens this year' do
      Timecop.freeze(Time.zone.local(2019, 1, 1)) do
        expect(person.next_birthday).to eq(Date.new(2019, 1, 10))
      end
    end

    it 'works when next birthday happens next year, in a different month' do
      Timecop.freeze(Time.zone.local(2018, 12, 30)) do
        expect(person.next_birthday).to eq(Date.new(2019, 1, 10))
      end
    end

    it 'works when next birthday happens next year, in the same month' do
      Timecop.freeze(Time.zone.local(2018, 1, 11)) do
        expect(person.next_birthday).to eq(Date.new(2019, 1, 10))
      end
    end
  end
end

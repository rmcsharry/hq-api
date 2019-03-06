# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contact::PersonDecorator do
  describe '#name and #name_list' do
    context 'without bells and whistles' do
      subject { build(:contact_person, first_name: 'Max', last_name: 'Mustermann').decorate }
      it 'responds with the full name' do
        expect(subject.name).to eq 'Max Mustermann'
        expect(subject.name_list).to eq 'Mustermann, Max'
      end
    end

    context 'with professional title' do
      subject do
        build(:contact_person, first_name: 'Max', last_name: 'Mustermann', professional_title: 'prof_dr').decorate
      end
      it 'responds with the full name and title' do
        expect(subject.name).to eq 'Prof. Dr. Max Mustermann'
        expect(subject.name_list).to eq 'Mustermann, Prof. Dr. Max'
      end
    end

    context 'with professional title and nobility title' do
      subject do
        build(
          :contact_person, first_name: 'Max', last_name: 'Mustermann', professional_title: 'prof_dr',
                           nobility_title: 'baron'
        ).decorate
      end
      it 'responds with the full name and all titles' do
        expect(subject.name).to eq 'Prof. Dr. Max Freiherr Mustermann'
        expect(subject.name_list).to eq 'Mustermann, Prof. Dr. Max Freiherr'
      end
    end

    context 'for an organization' do
      subject { build(:contact_organization, organization_name: 'HQ Trust GmbH').decorate }
      it 'responds with the full name' do
        expect(subject.name).to eq 'HQ Trust GmbH'
      end
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

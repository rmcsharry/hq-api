require 'rails_helper'

RSpec.describe Contact::OrganizationDecorator do
  describe '#name' do
    subject { build(:contact_person, first_name: 'Max', last_name: 'Mustermann').decorate }
    it 'responds with the full name' do
      expect(subject.name).to eq 'Max Mustermann'
    end
  end
end

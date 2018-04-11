require 'rails_helper'

RSpec.describe Contact::PersonDecorator do
  describe '#name' do
    subject { build(:contact_organization, organization_name: 'HQ Trust GmbH').decorate }
    it 'responds with the full name' do
      expect(subject.name).to eq 'HQ Trust GmbH'
    end
  end
end

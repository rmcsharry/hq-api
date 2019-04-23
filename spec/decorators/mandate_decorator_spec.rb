# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MandateDecorator do
  describe '#humanize_confidential' do
    it 'returns confidential in words' do
      expect(build(:mandate, confidential: true).decorate.humanize_confidential).to eq('Persönlich / Vertraulich')
    end

    it 'returns nil' do
      expect(build(:mandate).decorate.humanize_confidential).to be_nil
    end
  end

  describe '#owner_name' do
    let!(:person1) { create(:contact_person, first_name: 'Thomas', last_name: 'Makait') }
    let!(:person2) { create(:contact_person, first_name: 'Maria', last_name: 'Makait') }
    let!(:organization) { create(:contact_organization, organization_name: 'Novo Investments UG') }
    let!(:mandate_member1) { create(:mandate_member, contact: person1, member_type: 'owner') }
    let!(:mandate_member2) { create(:mandate_member, contact: person2, member_type: 'owner') }
    let!(:mandate_member3) { create(:mandate_member, contact: organization, member_type: 'owner') }
    subject { create(:mandate, mandate_members: owners).decorate }

    context 'all three are owners' do
      let(:owners) { [mandate_member1, mandate_member2, mandate_member3] }
      it 'responds with all names' do
        expect(subject.owner_name).to eq 'Makait, Maria, Makait, Thomas und Novo Investments UG'
      end
    end

    context 'person1 is owner' do
      let(:owners) { [mandate_member1] }
      it "responds with person1's name" do
        expect(subject.owner_name).to eq 'Makait, Thomas'
      end
    end

    context 'person1 and person2 are owners' do
      let(:owners) { [mandate_member1, mandate_member2] }
      it "responds with person1 and person2's names" do
        expect(subject.owner_name).to eq 'Makait, Maria und Makait, Thomas'
      end
    end

    context 'organization is owner' do
      let(:owners) { [mandate_member3] }
      it "responds with the organization's name" do
        expect(subject.owner_name).to eq 'Novo Investments UG'
      end
    end

    context 'nobody is owner' do
      let(:owners) { [] }
      it 'responds with an empty string' do
        expect(subject.owner_name).to eq ''
      end
    end
  end
end

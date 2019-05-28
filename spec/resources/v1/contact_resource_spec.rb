# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ::V1::ContactResource, type: :resource do
  let(:contact) { create(:contact_person) }
  subject { described_class.new(Contact.with_name.find(contact.id), {}) }

  it { is_expected.to have_attribute :comment }
  it { is_expected.to have_attribute :commercial_register_number }
  it { is_expected.to have_attribute :commercial_register_office }
  it { is_expected.to have_attribute :contact_type }
  it { is_expected.to have_attribute :date_of_birth }
  it { is_expected.to have_attribute :date_of_death }
  it { is_expected.to have_attribute :first_name }
  it { is_expected.to have_attribute :gender }
  it { is_expected.to have_attribute :is_mandate_member }
  it { is_expected.to have_attribute :is_mandate_owner }
  it { is_expected.to have_attribute :last_name }
  it { is_expected.to have_attribute :legal_address_text }
  it { is_expected.to have_attribute :maiden_name }
  it { is_expected.to have_attribute :name }
  it { is_expected.to have_attribute :name_list }
  it { is_expected.to have_attribute :nationality }
  it { is_expected.to have_attribute :nobility_title }
  it { is_expected.to have_attribute :organization_category }
  it { is_expected.to have_attribute :organization_industry }
  it { is_expected.to have_attribute :organization_name }
  it { is_expected.to have_attribute :organization_type }
  it { is_expected.to have_attribute :place_of_birth }
  it { is_expected.to have_attribute :primary_contact_address_text }
  it { is_expected.to have_attribute :professional_title }
  it { is_expected.to have_attribute :updated_at }

  it { is_expected.to have_many(:active_contact_relationships).with_class_name('ContactRelationship') }
  it { is_expected.to have_many(:passive_contact_relationships).with_class_name('ContactRelationship') }
  it { is_expected.not_to have_many(:actively_related_people).with_class_name('Contact::Person') }
  it { is_expected.not_to have_many(:passively_related_people).with_class_name('Contact::Person') }
  it { is_expected.not_to have_many(:actively_related_organizations).with_class_name('Contact::Organization') }
  it { is_expected.not_to have_many(:passively_related_organizations).with_class_name('Contact::Organization') }
  it { is_expected.to have_many(:addresses) }
  it { is_expected.to have_many(:contact_details) }
  it { is_expected.to have_many(:documents) }
  it { is_expected.to have_many(:investors) }
  it { is_expected.to have_many(:mandate_members) }
  it { is_expected.to have_one(:compliance_detail) }
  it { is_expected.to have_one(:legal_address).with_class_name('Address') }
  it { is_expected.to have_one(:primary_contact_address).with_class_name('Address') }
  it { is_expected.to have_one(:primary_email).with_class_name('ContactDetail') }
  it { is_expected.to have_one(:primary_phone).with_class_name('ContactDetail') }

  it { is_expected.to filter(:"compliance_detail.occupation_role") }
  it { is_expected.to filter(:"compliance_detail.occupation_title") }
  it { is_expected.to filter(:"email.value") }
  it { is_expected.to filter(:"fax.value") }
  it { is_expected.to filter(:"phone.value") }
  it { is_expected.to filter(:"primary_email.value") }
  it { is_expected.to filter(:"primary_phone.value") }
  it { is_expected.to filter(:comment) }
  it { is_expected.to filter(:commercial_register_number) }
  it { is_expected.to filter(:commercial_register_office) }
  it { is_expected.to filter(:contact_type) }
  it { is_expected.to filter(:date_of_birth_max) }
  it { is_expected.to filter(:date_of_birth_min) }
  it { is_expected.to filter(:date_of_death_max) }
  it { is_expected.to filter(:date_of_death_min) }
  it { is_expected.to filter(:first_name) }
  it { is_expected.to filter(:gender) }
  it { is_expected.to filter(:is_mandate_member) }
  it { is_expected.to filter(:is_mandate_owner) }
  it { is_expected.to filter(:last_name) }
  it { is_expected.to filter(:legal_address_text) }
  it { is_expected.to filter(:maiden_name) }
  it { is_expected.to filter(:mandate_member_by_mandate_id_and_type) }
  it { is_expected.to filter(:name) }
  it { is_expected.to filter(:name_list) }
  it { is_expected.to filter(:nationality) }
  it { is_expected.to filter(:nobility_title) }
  it { is_expected.to filter(:not_in_list_with_id) }
  it { is_expected.to filter(:organization_category) }
  it { is_expected.to filter(:organization_industry) }
  it { is_expected.to filter(:organization_name) }
  it { is_expected.to filter(:organization_type) }
  it { is_expected.to filter(:place_of_birth) }
  it { is_expected.to filter(:primary_contact_address_text) }
  it { is_expected.to filter(:professional_title) }

  it { is_expected.to have_sortable_field(:"compliance_detail.occupation_role") }
  it { is_expected.to have_sortable_field(:"compliance_detail.occupation_title") }
  it { is_expected.to have_sortable_field(:is_mandate_member) }
  it { is_expected.to have_sortable_field(:is_mandate_owner) }
  it { is_expected.to have_sortable_field(:legal_address_text) }
  it { is_expected.to have_sortable_field(:primary_contact_address_text) }

  describe '#name' do
    context 'person' do
      let(:contact) { create(:contact_person, first_name: 'Max', last_name: 'Mustermann') }

      it "responds with the person's full name" do
        expect(subject.name).to eq 'Max Mustermann'
      end
    end

    context 'organization' do
      let(:contact) { create(:contact_organization, organization_name: 'HQ Trust GmbH') }

      it "responds with the organization's name" do
        expect(subject.name).to eq 'HQ Trust GmbH'
      end
    end
  end

  describe '#name_list' do
    context 'person' do
      let(:contact) { create(:contact_person, first_name: 'Max', last_name: 'Mustermann') }

      it "responds with the person's full name in list style" do
        expect(subject.name_list).to eq 'Mustermann, Max'
      end
    end

    context 'organization' do
      let(:contact) { create(:contact_organization, organization_name: 'HQ Trust GmbH') }

      it "responds with the organization's name" do
        expect(subject.name_list).to eq 'HQ Trust GmbH'
      end
    end
  end
end

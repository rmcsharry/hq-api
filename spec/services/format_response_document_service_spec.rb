# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe 'FormatResponseDocumentService', type: :request do
  let!(:contact) { create_contact }
  let!(:user) { create(:user, contact: contact, roles: %i[contacts_read contacts_write]) }
  let(:headers) { { 'Accept' => 'application/vnd.api+json' } }
  let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers(headers, user) }
  let(:request) { -> { get(endpoint, params: params, headers: auth_headers) } }

  let(:context) do
    {
      current_user: user
    }
  end

  def create_address(contact)
    create(
      :address,
      owner: contact,
      postal_code: Faker::Address.zip_code,
      city: Faker::Address.city,
      country: Faker::Address.country_code,
      addition: rand > 0.6 ? Faker::Address.secondary_address : nil,
      category: Address::CATEGORIES.sample,
      street_and_number: Faker::Address.street_address
    )
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def create_contact
    contact = create(
      :contact_person,
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      comment: Faker::Company.catch_phrase,
      gender: 'female',
      nobility_title: Contact::Person::NOBILITY_TITLES.sample,
      professional_title: Contact::Person::PROFESSIONAL_TITLES.sample,
      maiden_name: Faker::Name.last_name,
      date_of_birth: Faker::Date.birthday(18, 82),
      date_of_death: Faker::Date.birthday(0, 17),
      nationality: Faker::Address.country_code
    )
    contact.legal_address = create_address(contact)
    contact.primary_contact_address = create_address(contact)
    contact.contact_details << create(:email, contact: contact, primary: true)
    contact.contact_details << create(:phone, contact: contact, primary: true)
    contact.compliance_detail = create(:compliance_detail, contact: contact)
    contact.save!
    contact
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  before do
    allow_any_instance_of(ApplicationController).to receive(:serialization_options) do
      {
        format: :xlsx
      }
    end
  end

  describe 'contacts', bullet: false do
    let(:endpoint) { CONTACTS_ENDPOINT }
    let(:params) do
      {
        sort: 'name',
        order: 'ASC',
        filter: {},
        include: 'compliance-detail,legal-address,primary-contact-address,primary-email,primary-phone,contact-details'
      }
    end

    before do
      request.call
      response_body = JSON.parse(response.body)
      @result = FormatResponseDocumentService.call response_body
    end

    it 'extracts contacts, all included resources, and join-table' do
      expected_sheets = %w[ComplianceDetails Contacts Addresses ContactDetails Contacts_ContactDetails]
      expect(@result.keys).to match_array(expected_sheets)
    end

    it 'formats the existing contact' do
      contacts = @result['Contacts']
      expected_number_of_contacts = 1

      attributes = V1::ContactResource._attributes.keys.map(&:to_s).map(&:dasherize).flat_map do |att|
        [att, "#{att}-text"]
      end
      relationships = V1::ContactResource._relationships.keys.map(&:to_s).map(&:dasherize).flat_map do |rel|
        [rel, "#{rel}-text"]
      end
      allowed_headers = attributes + relationships

      expect(contacts.size).to eq(expected_number_of_contacts + 1)
      expect(allowed_headers).to include(*contacts.first)
      expect(contacts.first.size).to eq(contacts.second.size)
    end

    it 'includes the two set addresses' do
      resources = @result['Addresses']
      expected_number_of_addresses = 2

      expect(resources.size).to eq(expected_number_of_addresses + 1)
    end

    it 'includes the two set contact details' do
      resources = @result['ContactDetails']
      expected_number_of_contact_details = 2

      expect(resources.size).to eq(expected_number_of_contact_details + 1)
    end

    it 'includes join table for contacts onto contact_details' do
      resources = @result['Contacts_ContactDetails']
      expected_number_of_rows = 2

      expect(resources.size).to eq(expected_number_of_rows + 1)
    end

    it 'includes join table for contacts onto contact_details' do
      resources = @result['Contacts_ContactDetails']
      expected_number_of_rows = 2

      expect(resources.size).to eq(expected_number_of_rows + 1)
    end

    it 'pretty prints relationships' do
      contacts = @result['Contacts']
      contact_data = contacts.first.zip(contacts.second).to_h
      address = contact.primary_contact_address
      expected_address_string = [
        address.street_and_number,
        address.addition,
        address.postal_code,
        address.city,
        address.country
      ].compact.join(', ')

      expect(contact_data['primary-contact-address']).to eq(address.id)
      expect(contact_data['primary-contact-address-text']).to eq(expected_address_string)
    end

    it 'pretty prints enums' do
      contacts = @result['Contacts']
      contact_data = contacts.first.zip(contacts.second).to_h

      expect(contact_data['gender']).to eq('female')
      expect(contact_data['gender-text']).to eq('Frau')
    end
  end

  describe 'contact versions' do
    let(:endpoint) { "#{CONTACTS_ENDPOINT}/#{contact.id}/versions" }
    let(:params) do
      {
        sort: 'created-at',
        order: 'ASC',
        filter: {},
        include: ''
      }
    end

    before do
      request.call
      response_body = JSON.parse(response.body)
      @result = FormatResponseDocumentService.call response_body
    end

    it 'extracts versions' do
      expect(@result.keys).to match_array(%w[Versions])
    end
  end

  describe 'contact#show', bullet: false do
    let(:endpoint) { "#{CONTACTS_ENDPOINT}/#{contact.id}" }
    let(:params) do
      {
        include: 'primary-contact-address'
      }
    end

    before do
      request.call
      response_body = JSON.parse(response.body)
      @result = FormatResponseDocumentService.call response_body
    end

    it 'extracts versions' do
      expected_sheets = %w[Addresses Contacts]
      expect(@result.keys).to match_array(expected_sheets)
    end
  end

  describe 'contact versions', bullet: false do
    let(:endpoint) { "#{CONTACTS_ENDPOINT}/#{contact.id}/versions" }
    let(:params) do
      {
        sort: 'created_at',
        order: 'DESC',
        filter: {},
        include: ''
      }
    end

    before do
      request.call
      response_body = JSON.parse(response.body)
      @result = FormatResponseDocumentService.call response_body
    end

    it 'extracts versions' do
      expected_sheets = %w[Versions]
      expect(@result.keys).to match_array(expected_sheets)
    end
  end
end

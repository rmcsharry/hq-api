# rubocop:disable Metrics/BlockLength
namespace :db do
  desc 'Populate test data'
  task populate: ['db:schema:load'] do
    populate 'users' do
      password = 'testmctest1A!'
      User.create!(email: 'admin@hqfinanz.de', password: password, confirmed_at: 1.day.ago)
      User.create!(email: 'sales@hqfinanz.de', password: password, confirmed_at: 1.day.ago)
      User.create!(email: 'bookkeeper@hqfinanz.de', password: password, confirmed_at: 1.day.ago)
    end

    populate 'contact persons' do
      contacts = Array.new(86) do
        Contact::Person.new(
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          comment: Faker::RickAndMorty.quote,
          gender: Contact::Person::GENDERS.sample,
          nobility_title: rand > 0.8 ? Contact::Person::NOBILITY_TITLES.sample : nil,
          professional_title: rand > 0.5 ? Contact::Person::PROFESSIONAL_TITLES.sample : nil,
          maiden_name: rand > 0.5 ? Faker::Name.last_name : nil,
          date_of_birth: Faker::Date.birthday(18, 82),
          date_of_death: rand > 0.9 ? Faker::Date.birthday(0, 17) : nil,
          nationality: Faker::Address.country_code
        )
      end
      Contact::Person.import!(contacts)
      addresses = []
      contacts_with_addresses = contacts.map do |contact|
        contact = contact_with_addresses(contact)
        addresses << [contact.legal_address, contact.primary_contact_address].uniq
        contact
      end
      Address.import!(addresses.flatten)
      Contact::Person.import!(
        contacts_with_addresses, on_duplicate_key_update: %i[primary_contact_address_id legal_address_id]
      )
    end

    populate 'contact organizations' do
      addresses = []
      contacts = Array.new(35) do
        Contact::Organization.new(
          organization_name: Faker::Company.name,
          organization_type: Contact::Organization::ORGANIZATION_TYPES.sample,
          organization_category: Faker::Company.type,
          organization_industry: Faker::Company.industry,
          commercial_register_number: Faker::Company.duns_number,
          commercial_register_office: Faker::Address.city
        )
      end
      Contact::Organization.import!(contacts)
      addresses = []
      contacts_with_addresses = contacts.map do |contact|
        contact = contact_with_addresses(contact)
        addresses << [contact.legal_address, contact.primary_contact_address].uniq
        contact
      end
      Address.import!(addresses.flatten)
      Contact::Organization.import!(
        contacts_with_addresses, on_duplicate_key_update: %i[primary_contact_address_id legal_address_id]
      )
    end

    populate 'tax details' do
      generate_person_tax_details
      generate_organization_tax_details
    end

    populate 'compliance details' do
      generate_person_compliance_details
      generate_organization_compliance_details
    end

    populate 'contact details' do
      contact_details = Contact.all.map do |contact|
        categories = contact.organization? ? %i[work] : ContactDetail::CATEGORIES
        [
          ContactDetail::Phone.new(
            contact: contact,
            category: categories.sample,
            value: "+4930#{Faker::Number.number(7)}",
            primary: true
          ),
          ContactDetail::Phone.new(
            contact: contact,
            category: categories.sample,
            value: "+4930#{Faker::Number.number(7)}",
            primary: false
          ),
          ContactDetail::Fax.new(
            contact: contact,
            category: categories.sample,
            value: "+4930#{Faker::Number.number(7)}",
            primary: true
          ),
          ContactDetail::Email.new(
            contact: contact,
            category: categories.sample,
            value: Faker::Internet.email,
            primary: true
          ),
          ContactDetail::Email.new(
            contact: contact,
            category: categories.sample,
            value: Faker::Internet.email,
            primary: false
          ),
          ContactDetail::Website.new(
            contact: contact,
            category: categories.sample,
            value: Faker::Internet.url,
            primary: false
          )
        ]
      end
      ContactDetail.import!(contact_details.flatten)
    end

    populate 'mandates' do
      contacts = Contact::Person.all
      mandates = Array.new(48) do
        valid_from = Faker::Date.between(15.years.ago, Time.zone.today)
        Mandate.new(
          aasm_state: %i[prospect client cancelled].sample,
          category: Mandate::CATEGORIES.sample,
          comment: Faker::RickAndMorty.quote,
          valid_from: valid_from,
          valid_to: rand > 0.8 ? Faker::Date.between(valid_from, 5.years.from_now) : nil,
          datev_creditor_id: Faker::Number.number(10),
          datev_debitor_id: Faker::Number.number(10),
          psplus_id: Faker::Number.number(10),
          primary_consultant: contacts.sample,
          secondary_consultant: contacts.sample,
          assistant_id: contacts.sample,
          bookkeeper_id: contacts.sample
        )
      end
      Mandate.import!(mandates)
    end

    populate 'mandate members' do
      contacts = Contact.all
      mandate_members = Mandate.all.map do |mandate|
        generate_mandate_members(mandate: mandate, contacts: contacts)
      end
      MandateMember.import!(mandate_members.flatten)
    end

    populate 'mandate groups' do
      mandates = Mandate.all
      families = Array.new(32) do
        MandateGroup.new(
          name: Faker::GameOfThrones.house,
          group_type: :family,
          mandates: mandates.sample(Faker::Number.between(2, 12))
        )
      end
      organizations = Array.new(12) do
        MandateGroup.new(
          name: Faker::Company.name,
          group_type: :organization,
          mandates: mandates.sample(Faker::Number.between(5, 34))
        )
      end
      MandateGroup.import!(families + organizations)
    end

    populate 'user groups' do
      UserGroup.create!(
        name: 'Administratoren',
        users: [User.first]
      )
      UserGroup.create!(
        name: 'HQ Trust',
        users: User.all
      )
    end

    populate 'activities' do
      participants = { contacts: Contact.all, mandates: Mandate.all }
      users = User.all
      activities = Array.new(432) do
        participant_class = rand > 0.5 ? :contacts : :mandates
        started_at = Faker::Time.between(5.years.ago, Time.zone.today, :day)
        [Activity::Call, Activity::Email, Activity::Meeting, Activity::Note].sample.new(
          started_at: started_at,
          ended_at: started_at + 1.hour,
          title: Faker::Company.catch_phrase,
          description: Faker::Movie.quote,
          creator: users.sample,
          participant_class => participants[participant_class].sample(Faker::Number.between(1, 5))
        )
      end
      Activity.import!(activities)
    end

    populate 'documents' do
      users = User.all
      owners = [Contact.all, Mandate.all, Activity.all].flatten
      documents = Array.new(847) do
        valid_from = Faker::Date.between(15.years.ago, Time.zone.today)
        Document.new(
          name: Faker::SiliconValley.invention,
          category: Document::CATEGORIES.sample,
          valid_from: valid_from,
          valid_to: rand > 0.8 ? Faker::Date.between(valid_from, 5.years.from_now) : nil,
          uploader: users.sample,
          owner: owners.sample,
          file: Rails.root.join('spec', 'fixtures', 'pdfs', 'hqtrust_sample.pdf')
        )
      end
      Document.import!(documents)
    end
  end

  def populate(name)
    print "Populating #{name}... "
    yield
    puts 'done'
  end

  def contact_with_addresses(contact)
    contact.legal_address = build_address(contact)
    contact.primary_contact_address = rand > 0.6 ? build_address(contact) : contact.legal_address
    contact
  end

  def build_address(contact)
    Address.new(
      contact: contact,
      postal_code: Faker::Address.zip_code,
      city: Faker::Address.city,
      country: Faker::Address.country_code,
      addition: rand > 0.6 ? Faker::Address.secondary_address : nil,
      category: Address::CATEGORIES.sample,
      street_and_number: Faker::Address.street_address
    )
  end

  def generate_person_tax_details
    tax_details = Contact::Person.all.map do |contact|
      us_tax = Faker::Boolean.boolean(0.2)
      create_person_tax_detail(contact: contact, us_tax: us_tax)
    end
    TaxDetail.import!(tax_details, recursive: true)
  end

  # rubocop:disable Metrics/MethodLength
  def create_person_tax_detail(contact:, us_tax:)
    tax_detail = TaxDetail.new(
      contact: contact,
      de_tax_number: '21/815/08150',
      de_tax_id: '12345678911',
      de_tax_office: Faker::Address.city,
      de_retirement_insurance: Faker::Boolean.boolean,
      de_unemployment_insurance: Faker::Boolean.boolean,
      de_health_insurance: Faker::Boolean.boolean,
      de_church_tax: Faker::Boolean.boolean,
      us_tax_number: us_tax ? Faker::Number.number(10) : nil,
      us_tax_form: us_tax ? TaxDetail::US_TAX_FORMS.sample : nil,
      us_fatca_status: us_tax ? TaxDetail::US_FATCA_STATUSES.sample : nil,
      common_reporting_standard: Faker::Boolean.boolean
    )
    generate_foreign_tax_numbers(tax_detail)
    tax_detail
  end
  # rubocop:enable Metrics/MethodLength

  def generate_organization_tax_details
    tax_details = Contact::Organization.all.map do |contact|
      us_tax = Faker::Boolean.boolean(0.2)
      create_organization_tax_detail(contact: contact, us_tax: us_tax)
    end
    TaxDetail.import!(tax_details, recursive: true)
  end

  # rubocop:disable Metrics/MethodLength
  def create_organization_tax_detail(contact:, us_tax:)
    tax_detail = TaxDetail.new(
      contact: contact,
      de_tax_number: '21/815/08150',
      de_tax_id: '12345678911',
      de_tax_office: Faker::Address.city,
      us_tax_number: us_tax ? Faker::Number.number(10) : nil,
      us_tax_form: us_tax ? TaxDetail::US_TAX_FORMS.sample : nil,
      us_fatca_status: us_tax ? TaxDetail::US_FATCA_STATUSES.sample : nil,
      common_reporting_standard: Faker::Boolean.boolean,
      eu_vat_number: 'DE999999999',
      legal_entity_identifier: Faker::Company.ein,
      transparency_register: Faker::Boolean.boolean
    )
    generate_foreign_tax_numbers(tax_detail)
    tax_detail
  end
  # rubocop:enable Metrics/MethodLength

  def generate_foreign_tax_numbers(tax_detail)
    return if Faker::Boolean.boolean(0.6)
    tax_detail.foreign_tax_numbers = Array.new(Faker::Number.between(1, 4)) do
      ForeignTaxNumber.new(
        tax_detail: tax_detail,
        tax_number: Faker::Number.number(10),
        country: Faker::Address.country_code
      )
    end
  end

  # rubocop:disable Metrics/MethodLength
  def generate_person_compliance_details
    compliance_details = Contact::Person.all.map do |contact|
      ComplianceDetail.new(
        contact: contact,
        wphg_classification: ComplianceDetail::WPHG_CLASSIFICATIONS.sample,
        kagb_classification: ComplianceDetail::KAGB_CLASSIFICATIONS.sample,
        politically_exposed: Faker::Boolean.boolean(0.2),
        occupation_role: ComplianceDetail::OCCUPATION_ROLES.sample,
        occupation_title: Faker::Job.title,
        retirement_age: Faker::Number.between(64, 68)
      )
    end
    ComplianceDetail.import!(compliance_details)
  end
  # rubocop:enable Metrics/MethodLength

  def generate_organization_compliance_details
    compliance_details = Contact::Organization.all.map do |contact|
      ComplianceDetail.new(
        contact: contact,
        wphg_classification: ComplianceDetail::WPHG_CLASSIFICATIONS.sample,
        kagb_classification: ComplianceDetail::KAGB_CLASSIFICATIONS.sample
      )
    end
    ComplianceDetail.import!(compliance_details)
  end

  def generate_mandate_members(mandate:, contacts:)
    owner = MandateMember.new(
      contact: contacts.sample,
      mandate: mandate,
      member_type: :owner
    )
    other_mandate_members = Array.new(Faker::Number.between(0, 10)) do
      start_date = rand > 0.8 ? Faker::Date.between(15.years.ago, 1.year.from_now) : nil
      create_other_mandate_member(mandate: mandate, contacts: contacts, start_date: start_date)
    end
    [owner, other_mandate_members].flatten
  end

  def create_other_mandate_member(mandate:, contacts:, start_date:)
    MandateMember.new(
      contact: contacts.sample,
      mandate: mandate,
      member_type: (MandateMember::MEMBER_TYPES - [:owner]).sample,
      start_date: start_date,
      end_date: start_date ? Faker::Date.between(start_date, 3.years.from_now) : nil
    )
  end
end
# rubocop:enable Metrics/BlockLength

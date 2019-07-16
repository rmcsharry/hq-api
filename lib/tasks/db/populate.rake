# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :db do
  desc 'Populate test data'
  task populate: [:environment, 'db:schema:load'] do
    ActiveRecord::Base.transaction do
      puts 'Creating contact persons'
      Rake::Task['db:populate:contact_persons'].invoke

      puts 'Creating contact organization'
      Rake::Task['db:populate:contact_organizations'].invoke

      puts 'Creating users'
      Rake::Task['db:populate:users'].invoke

      puts 'Creating tax details'
      Rake::Task['db:populate:tax_details'].invoke

      puts 'Creating compliance details'
      Rake::Task['db:populate:compliance_details'].invoke

      puts 'Creating contact details'
      Rake::Task['db:populate:contact_details'].invoke

      puts 'Creating mandate groups'
      Rake::Task['db:populate:mandate_groups'].invoke

      puts 'Creating mandates'
      Rake::Task['db:populate:mandates'].invoke

      puts 'Creating bank accounts'
      Rake::Task['db:populate:bank_accounts'].invoke

      puts 'Creating mandate members'
      Rake::Task['db:populate:mandate_members'].invoke

      puts 'Creating contact relationships'
      Rake::Task['db:populate:contact_relationships'].invoke

      puts 'Creating user groups'
      Rake::Task['db:populate:user_groups'].invoke

      puts 'Creating activities'
      Rake::Task['db:populate:activities'].invoke

      puts 'Creating funds'
      Rake::Task['db:populate:funds'].invoke

      puts 'Creating investors'
      Rake::Task['db:populate:investors'].invoke

      puts 'Creating fund reports'
      Rake::Task['db:populate:fund_reports'].invoke

      puts 'Creating fund cashflows'
      Rake::Task['db:populate:fund_cashflows'].invoke

      puts 'Creating documents'
      Rake::Task['db:populate:documents'].invoke

      puts 'Creating tasks and reminders'
      Rake::Task['db:populate:tasks_and_reminders'].invoke

      puts 'Creating lists'
      Rake::Task['db:populate:lists'].invoke
    end
  end

  namespace :populate do
    task contact_persons: :environment do
      contacts = Array.new(86) do
        Contact::Person.new(
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          comment: Faker::Company.catch_phrase,
          gender: Contact::Person::GENDERS.sample,
          nobility_title: rand > 0.8 ? Contact::Person::NOBILITY_TITLES.sample : nil,
          professional_title: rand > 0.5 ? Contact::Person::PROFESSIONAL_TITLES.sample : nil,
          maiden_name: rand > 0.5 ? Faker::Name.last_name : nil,
          place_of_birth: rand > 0.4 ? Faker::Address.city : nil,
          date_of_birth: Faker::Date.birthday(18, 82),
          date_of_death: rand > 0.9 ? Faker::Date.birthday(0, 17) : nil,
          nationality: Faker::Address.country_code
        )
      end
      arne = Contact::Person.new(
        gender: :male,
        first_name: 'Arne',
        last_name: 'Zeising'
      )
      contacts << arne
      contacts << Contact::Person.new(
        gender: :male,
        first_name: 'Jerome',
        last_name: 'Burkhard'
      )
      contacts << Contact::Person.new(
        gender: :male,
        first_name: 'Sophia',
        last_name: 'Burkhard'
      )
      jolina = Contact::Person.new(
        gender: :female,
        first_name: 'Jolina',
        last_name: 'Badane'
      )
      contacts << jolina
      Contact::Person.import!(contacts)
      addresses = []
      contacts_with_addresses = contacts.map do |contact|
        contact = owner_with_addresses(contact)
        addresses << [contact.legal_address, contact.primary_contact_address].uniq
        contact
      end
      Address.import!(addresses.flatten)
      Contact::Person.import!(
        contacts_with_addresses, on_duplicate_key_update: %i[primary_contact_address_id legal_address_id]
      )
      ContactDetail::Phone.create(
        contact: arne,
        category: :private,
        value: '+4917098765432'
      )
      ContactDetail::Email.create(
        contact: arne,
        category: :private,
        value: 'arne@shr.ps'
      )
      ContactDetail::Fax.create(
        contact: arne,
        category: :work,
        value: '+493032101234'
      )
      ContactDetail::Phone.create(
        contact: jolina,
        category: :work,
        value: '+49308054038'
      )
    end

    task contact_organizations: :environment do
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
      contacts << Contact::Organization.new(
        organization_name: 'Sherpas Digital Ventures GmbH',
        organization_type: :gmbh
      )
      Contact::Organization.import!(contacts)
      addresses = []
      contacts_with_addresses = contacts.map do |contact|
        contact = owner_with_addresses(contact)
        addresses << [contact.legal_address, contact.primary_contact_address].uniq
        contact
      end
      Address.import!(addresses.flatten)
      Contact::Organization.import!(
        contacts_with_addresses, on_duplicate_key_update: %i[primary_contact_address_id legal_address_id]
      )
    end

    task users: :environment do
      password = 'testmctest1A!'
      User.create!(
        email: 'admin@hqfinanz.de',
        password: password,
        confirmed_at: 1.day.ago,
        contact: Contact.where(type: 'Contact::Person').sample,
        comment: Faker::Company.catch_phrase,
        ews_user_id: '008c2269-2676-42a2-9f5d-d2e60ed85b28' # user id of test.sherpas@hqtrust.de in verticals EWS
      )

      [
        'AI Administrator',
        'Assistenz',
        'Buchhaltung',
        'Compliance',
        'Controlling',
        'Familien',
        'HQ AM',
        'HQA Geschäftsführung',
        'HQT Geschäftsführung',
        'Institutionell',
        'Investment',
        'Kontakte',
        'Kundenberater',
        'PVT'
      ].each do |name|
        User.create!(
          email: "#{name.parameterize}@hqfinanz.de",
          password: password,
          confirmed_at: 1.day.ago,
          contact: Contact.where(type: 'Contact::Person').sample,
          comment: Faker::TvShows::SiliconValley.quote
        )
      end
    end

    task tax_details: :environment do
      generate_person_tax_details
      generate_organization_tax_details
    end

    task compliance_details: :environment do
      generate_person_compliance_details
      generate_organization_compliance_details
    end

    task contact_details: :environment do
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
            primary: !contact.user
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
      contact_details << User.all.map do |user|
        ContactDetail::Email.new(contact: user.contact, category: :work, value: user.email, primary: true)
      end
      ContactDetail.import!(contact_details.flatten)
    end

    task mandate_groups: :environment do
      mandates_groups_families = Array.new(32) do |i|
        MandateGroup.new(
          comment: Faker::Company.catch_phrase,
          group_type: :family,
          name: "#{Faker::Company.name} ##{i}" # Uniqueness of names is needed for e2e tests
        )
      end
      MandateGroup.import!(mandates_groups_families)
      MandateGroup.create!(
        comment: Faker::Company.catch_phrase,
        group_type: :organization,
        name: 'HQ Trust'
      )
      MandateGroup.create!(
        comment: Faker::Company.catch_phrase,
        group_type: :organization,
        name: 'HQ Asset Servicing'
      )
    end

    task mandates: :environment do
      contacts = Contact::Person.all
      admin_user = User.find_by(email: 'admin@hqfinanz.de')
      mandate_groups_organizations = MandateGroup.organizations
      mandate_groups_organizations_length = mandate_groups_organizations.length
      mandate_groups_families = MandateGroup.families
      mandate_groups_families_length = mandate_groups_families.length
      special_family = mandate_groups_families.first
      48.times do |i|
        valid_from = Faker::Date.between(15.years.ago, Time.zone.today)
        state = %i[prospect_not_qualified client cancelled].sample
        Mandate.create(
          aasm_state: state,
          assistant: contacts.sample,
          bookkeeper: contacts.sample,
          category: Mandate::CATEGORIES.sample,
          comment: Faker::Company.catch_phrase,
          datev_creditor_id: Faker::Number.number(10),
          datev_debitor_id: Faker::Number.number(10),
          default_currency: state == :prospect_not_qualified ? 'EUR' : nil,
          mandate_groups_families: [special_family] | [mandate_groups_families[i % mandate_groups_families_length]],
          mandate_groups_organizations: [mandate_groups_organizations[i % mandate_groups_organizations_length]],
          mandate_number: "#{Faker::Number.number(3)}-#{Faker::Number.number(3)}-#{Faker::Number.number(3)}",
          primary_consultant: contacts.sample,
          prospect_assets_under_management:
            state == :prospect_not_qualified ? (Faker::Number.between(500, 50_000) * 1000).to_f : nil,
          prospect_fees_fixed_amount:
            state == :prospect_not_qualified ? (Faker::Number.between(100, 1_000) * 10).to_f : nil,
          prospect_fees_min_amount:
            state == :prospect_not_qualified ? (Faker::Number.between(50, 1_500) * 10).to_f : nil,
          prospect_fees_percentage:
            state == :prospect_not_qualified ? (Faker::Number.between(1, 250).to_f / 10_000).round(2) : nil,
          psplus_id: Faker::Number.number(9),
          psplus_pe_id: Faker::Number.number(9),
          secondary_consultant: admin_user.contact,
          valid_from: valid_from,
          valid_to: rand > 0.8 ? Faker::Date.between(valid_from, 5.years.from_now) : nil
        )
      end
    end

    task mandate_members: :environment do
      contacts = Contact.all
      mandate_members = Mandate.all.map do |mandate|
        MandateMember.new(contact: contacts.sample, mandate: mandate, member_type: :owner)
      end
      MandateMember.import!(mandate_members)
    end

    task contact_relationships: :environment do
      relationships = []

      Contact::Person.all.each do |source_person|
        relationships << generate_contact_relationships(
          source_contact: source_person,
          target_class: Contact::Person,
          valid_roles: ContactRelationship::PERSON_TO_PERSON_ROLES
        )

        relationships << generate_contact_relationships(
          source_contact: source_person,
          target_class: Contact::Organization,
          valid_roles: ContactRelationship::PERSON_TO_ORGANIZATION_ROLES
        )
      end

      Contact::Organization.all.each do |source_organization|
        relationships << generate_contact_relationships(
          source_contact: source_organization,
          target_class: Contact::Organization,
          valid_roles: ContactRelationship::ORGANIZATION_TO_ORGANIZATION_ROLES
        )
      end

      ContactRelationship.import!(relationships.flatten)
    end

    task user_groups: :environment do
      UserGroup.create!(
        comment: Faker::Company.catch_phrase,
        mandate_groups: MandateGroup.organizations.all,
        name: 'Administrator',
        roles: UserGroup::AVAILABLE_ROLES,
        users: [User.find_by(email: 'admin@hqfinanz.de')]
      )

      {
        'AI Administrator' => %i[alternative_investments funds_destroy funds_read funds_write tasks],
        'Assistenz' => %i[
          contacts_destroy contacts_read contacts_write families_destroy families_read families_write mandates_destroy
          mandates_read mandates_write tasks
        ],
        'Buchhaltung' => %i[contacts_read families_read mandates_read tasks],
        'Compliance' => %i[contacts_read families_read mandates_read tasks],
        'Controlling' => %i[
          contacts_destroy contacts_read contacts_write families_destroy families_read families_write mandates_destroy
          mandates_read mandates_write tasks
        ],
        'Familien' => %i[families_read],
        'HQA Geschäftsführung' => %i[
          contacts_destroy contacts_read contacts_write families_destroy families_read families_write mandates_destroy
          mandates_read mandates_write tasks
        ],
        'HQ AM' => %i[
          contacts_destroy contacts_read contacts_write families_destroy families_read families_write mandates_destroy
          mandates_read mandates_write tasks
        ],
        'HQT Geschäftsführung' => %i[
          contacts_destroy contacts_read contacts_write families_destroy families_read families_write mandates_destroy
          mandates_read mandates_write tasks
        ],
        'Institutionell' => %i[
          contacts_destroy contacts_read contacts_write families_destroy families_read families_write mandates_destroy
          mandates_read mandates_write tasks
        ],
        'Investment' => %i[
          contacts_destroy contacts_read contacts_write families_destroy families_read families_write mandates_destroy
          mandates_read mandates_write alternative_investments funds_read tasks
        ],
        'Kontakte' => %i[contacts_read],
        'Kundenberater' => %i[
          contacts_destroy contacts_read contacts_write families_destroy families_read families_write mandates_destroy
          mandates_read mandates_write alternative_investments funds_read tasks
        ],
        'PVT' => %i[
          contacts_destroy contacts_read contacts_write families_destroy families_read families_write mandates_destroy
          mandates_read mandates_write tasks
        ]
      }.each do |name, roles|
        UserGroup.create!(
          comment: Faker::TvShows::SiliconValley.quote,
          mandate_groups: MandateGroup.organizations.sample(Faker::Number.between(4, 12)),
          name: name,
          roles: roles,
          users: [User.find_by(email: "#{name.parameterize}@hqfinanz.de")]
        )
      end
    end

    task activities: :environment do
      participants = { contacts: Contact.all, mandates: Mandate.all }
      users = User.all
      432.times do
        participant_class = rand > 0.5 ? :contacts : :mandates
        started_at = Faker::Time.between(5.years.ago, Time.zone.today, :day)
        [Activity::Call, Activity::Email, Activity::Meeting, Activity::Note].sample.create(
          started_at: started_at,
          ended_at: started_at + 1.hour,
          title: Faker::Company.catch_phrase,
          description: Faker::Movie.quote,
          creator: users.sample,
          participant_class => participants[participant_class].sample(Faker::Number.between(1, 5))
        )
      end
    end

    task funds: :environment do
      funds = Array.new(23) do
        type = ['Fund::PrivateDebt', 'Fund::PrivateEquity', 'Fund::RealEstate'].sample
        Fund.new(
          aasm_state: %i[open closed liquidated].sample,
          type: type,
          comment: Faker::Company.catch_phrase,
          commercial_register_number: Faker::Company.duns_number,
          commercial_register_office: Faker::Address.city,
          company: rand > 0.5 ? "#{Faker::Company.name} #{Faker::Company.suffix}" : nil,
          currency: Fund::CURRENCIES.sample,
          duration: Faker::Number.between(5, 12),
          duration_extension: Faker::Number.between(0, 4),
          issuing_year: Faker::Number.between(2005, 2020),
          name: "#{Faker::Company.name} #{Faker::Company.suffix}",
          psplus_asset_id: Faker::Number.number(9),
          region: Fund::REGIONS.sample,
          strategy: type.constantize.const_get(:STRATEGIES).sample
        )
      end
      Fund.import!(funds)
      addresses = []
      funds_with_addresses = funds.map do |fund|
        fund = owner_with_addresses(fund)
        addresses << [fund.legal_address, fund.primary_contact_address].uniq
        fund
      end
      Address.import!(addresses.flatten)
      Fund.import!(
        funds_with_addresses, on_duplicate_key_update: %i[primary_contact_address_id legal_address_id]
      )
    end

    task investors: :environment do
      investors = []
      users = User.all

      Fund.all.each do |fund|
        number_of_investors = (1..5).to_a.sample
        Mandate
          .joins(:bank_accounts)
          .where('bank_accounts.id IS NOT NULL')
          .where.not(state: :prospect_not_qualified)
          .sample(number_of_investors).each do |mandate|
          primary_owner = mandate.owners.sample.contact

          state = %i[created signed].sample
          investor = Investor.new(
            aasm_state: state,
            amount_total: Faker::Number.between(100_000, 100_000_000).round(2),
            bank_account: mandate.bank_accounts.sample,
            contact_address: primary_owner.primary_contact_address,
            fund: fund,
            investment_date: state == :signed ? Faker::Date.between(2.years.ago, 0.days.ago) : nil,
            legal_address: primary_owner.legal_address,
            mandate: mandate,
            primary_owner: primary_owner
          )
          if state == :signed
            investor.build_fund_subscription_agreement(
              category: :fund_subscription_agreement,
              name: 'Zeichnungsschein',
              uploader: users.sample
            )
          end
          investors << investor
        end
      end

      Investor.import! investors, recursive: true
    end

    task fund_reports: :environment do
      Fund.all.each do |fund|
        Faker::Number.between(2, 5).times do
          FundReport.create(
            description: Faker::Movie.quote,
            dpi: (Faker::Number.between(100, 650).to_f / 10_000).round(2),
            fund: fund,
            irr: (Faker::Number.between(100, 650).to_f / 10_000).round(2),
            rvpi: (Faker::Number.between(100, 650).to_f / 10_000).round(2),
            tvpi: (Faker::Number.between(100, 650).to_f / 10_000).round(2),
            valuta_date: Faker::Date.between(6.years.ago, 0.days.ago)
          )
        end
      end
    end

    task fund_cashflows: :environment do
      fund_cashflows = []

      Fund.all.each do |fund|
        Faker::Number.between(2, 5).times do |i|
          fund_cashflows << FundCashflow.new(
            description_bottom: Faker::Movie.quote,
            description_top: Faker::Movie.quote,
            fund: fund,
            number: i + 1,
            valuta_date: Faker::Date.between(6.years.ago, 0.days.ago)
          )
        end
      end

      FundCashflow.import!(fund_cashflows)

      investor_cashflows = []

      FundCashflow.all.each do |fund_cashflow|
        fund_cashflow.fund.investors.signed.each do |investor|
          investor_cashflows << InvestorCashflow.new(
            fund_cashflow: fund_cashflow,
            investor: investor,
            aasm_state: rand > 0.2 ? :finished : :open,
            distribution_repatriation_amount: Faker::Number.between(0, 2_000_000),
            distribution_participation_profits_amount: Faker::Number.between(0, 2_000_000),
            distribution_dividends_amount: Faker::Number.between(0, 2_000_000),
            distribution_interest_amount: Faker::Number.between(0, 2_000_000),
            distribution_misc_profits_amount: Faker::Number.between(0, 2_000_000),
            distribution_structure_costs_amount: Faker::Number.between(0, 2_000_000),
            distribution_withholding_tax_amount: Faker::Number.between(0, 2_000_000),
            distribution_recallable_amount: Faker::Number.between(0, 2_000_000),
            distribution_compensatory_interest_amount: Faker::Number.between(0, 2_000_000),
            capital_call_gross_amount: Faker::Number.between(0, 2_000_000),
            capital_call_compensatory_interest_amount: Faker::Number.between(0, 2_000_000),
            capital_call_management_fees_amount: Faker::Number.between(0, 2_000_000)
          )
        end
      end

      InvestorCashflow.import!(investor_cashflows)
    end

    task documents: :environment do
      users = User.all
      owners = [Contact.all, Mandate.all, Activity.all].flatten
      documents = Array.new(847) do
        valid_from = Faker::Date.between(15.years.ago, Time.zone.today)
        generate_document(
          valid_from: valid_from,
          owner: owners.sample,
          uploader: users.sample
        )
      end
      Document.import!(documents)
      document = Document.first
      document.file.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'pdfs', 'hqtrust_sample.pdf')),
        filename: 'hqtrust_sample.pdf',
        content_type: 'application/pdf'
      )
      blob = document.file.blob
      Document.where.not(id: document.id).find_each do |doc|
        doc.file.attach(blob)
      end
    end

    task bank_accounts: :environment do
      bank_accounts = []
      banks = Contact::Organization.all
      # 10% should be banks
      banks = banks.sample((banks.length * 0.1).to_i)
      Mandate.all.map do |mandate|
        bank_accounts.push(generate_bank_accounts(mandate, banks))
      end
      BankAccount.import!(bank_accounts.flatten)
    end

    task tasks_and_reminders: :environment do
      admin_user = User.find_by(email: 'admin@hqfinanz.de')
      tasks = []
      task_comments = []

      Faker::Number.between(3, 6).times do
        assignees = User.order(Arel.sql('RANDOM()')).limit(Faker::Number.between(1, 4))
        due_at = rand > 0.5 ? nil : Faker::Date.between(0.days.from_now, 2.weeks.from_now)

        task = Task::Simple.new(
          assignees: assignees,
          creator: admin_user,
          description: Faker::Hacker.say_something_smart,
          due_at: due_at,
          title: Faker::Lebowski.quote
        )
        tasks << task

        Faker::Number.between(0, 6).times do
          task_comments << TaskComment.new(
            task: task,
            user: ([admin_user] + assignees).sample,
            comment: Faker::Hacker.say_something_smart
          )
        end
      end

      expiring_documents = Task::DocumentExpiryReminder.disregarded_documents_expiring_within(10.days)
      expiring_documents.each do |document|
        tasks << Task::DocumentExpiryReminder.new(subject: document)
      end

      birthday_contacts = Task::ContactBirthdayReminder.disregarded_contacts_with_birthday_within(10.days)
      birthday_contacts.each do |contact|
        tasks << Task::ContactBirthdayReminder.new(subject: contact)
      end

      Task.import! tasks
      TaskComment.import! task_comments

      Document.where.not(valid_to: nil).sample(2).each do |document|
        reminder = Task::DocumentExpiryReminder.new(subject: document)
        reminder.assignees << admin_user
        reminder.save
      end

      Contact.where.not(date_of_birth: nil).sample(2).each do |contact|
        reminder = Task::ContactBirthdayReminder.new(subject: contact)
        reminder.assignees << admin_user
        reminder.save
      end
    end

    task lists: :environment do
      20.times do
        items = []
        user = User.all.sample

        list = List.create!(
          name: Faker::Lorem.words.join(' ').titleize,
          comment: Faker::Lorem.sentences.join(' '),
          user: user
        )

        Contact.order(Arel.sql('RANDOM()')).limit(Random.rand(10)).map do |listable|
          items << List::Item.new(listable: listable, comment: Faker::Lorem.sentence)
        end

        Mandate.order(Arel.sql('RANDOM()')).limit(Random.rand(10)).map do |listable|
          items << List::Item.new(listable: listable, comment: Faker::Lorem.sentence)
        end

        list.items = items
      end
    end
  end

  def owner_with_addresses(owner)
    owner.legal_address = build_address(owner)
    owner.primary_contact_address = rand > 0.6 ? build_address(owner) : owner.legal_address
    owner
  end

  def build_address(owner)
    Address.new(
      addition: rand > 0.6 ? Faker::Address.secondary_address : nil,
      category: Address::CATEGORIES.sample,
      city: Faker::Address.city,
      country: Faker::Address.country_code,
      organization_name: rand > 0.6 ? Faker::Company.name : nil,
      owner: owner,
      postal_code: Faker::Address.zip_code,
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

  def generate_contact_relationships(source_contact:, target_class:, valid_roles:)
    target_class.all.sample(Faker::Number.between(0, 10)).map do |target_contact|
      ContactRelationship.new(
        comment: rand > 0.6 ? Faker::Company.catch_phrase : nil,
        source_contact: source_contact,
        target_contact: target_contact,
        role: valid_roles.sample
      )
    end
  end

  def generate_document(valid_from:, owner:, uploader:)
    Document.new(
      name: Faker::TvShows::SiliconValley.invention,
      category: Document::CATEGORIES.sample,
      valid_from: valid_from,
      valid_to: rand > 0.8 ? Faker::Date.between(valid_from, 5.years.from_now) : nil,
      uploader: uploader,
      owner: owner
    )
  end

  def generate_bank_accounts(mandate, banks)
    Array.new(rand(1..5)) do
      bank = banks.sample
      use_iban = Faker::Boolean.boolean(0.66)
      create_bank_account(mandate, bank, use_iban)
    end
  end

  # rubocop:disable Metrics/MethodLength
  def create_bank_account(owner, bank, use_iban)
    BankAccount.new(
      account_type: BankAccount::ACCOUNT_TYPE.sample,
      alternative_investments: true,
      bank: bank,
      bank_account_number: !use_iban ? Faker::Number.number(10) : nil,
      bank_routing_number: !use_iban ? Faker::Number.number(8) : nil,
      bic: use_iban ? Faker::Bank.swift_bic : nil,
      currency: BankAccount::CURRENCIES.sample,
      iban: use_iban ? IbanGenerator.random_iban : nil,
      owner: owner,
      owner_name: Faker::Name.name
    )
  end
  # rubocop:enable Metrics/MethodLength
end
# rubocop:enable Metrics/BlockLength

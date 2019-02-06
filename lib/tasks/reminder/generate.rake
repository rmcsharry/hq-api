# frozen_string_literal: true

namespace :reminder do
  namespace :generate do
    desc 'Create all available reminders'
    task all: :environment do
      puts 'Creating birthday reminders'
      Rake::Task['reminder:generate:birthday'].invoke

      puts 'Creating document expiry reminders'
      Rake::Task['reminder:generate:document_expiry'].invoke
    end

    desc 'Create reminders for contacts whose birthday is within 10 days'
    task birthday: :environment do
      contacts = Task::ContactBirthdayReminder.disregarded_contacts_with_birthday_within(10.days)
      contacts.each do |contact|
        Task::ContactBirthdayReminder.create subject: contact
      end
    end

    desc 'Generate reminders for documents expiring within 10 days'
    task document_expiry: :environment do
      documents = Task::DocumentExpiryReminder.disregarded_documents_expiring_within(10.days)
      documents.each do |document|
        Task::DocumentExpiryReminder.create subject: document
      end
    end
  end
end

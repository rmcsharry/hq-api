# frozen_string_literal: true

namespace :db do
  desc 'Calculate data integrity scores'
  task calculate_scores: :environment do
    ActiveRecord::Base.transaction do
      puts 'Calculating contact scores'
      Contact.all.each do |contact|
        contact.calculate_score
        contact.save!
      end
      puts 'Calculating mandate scores'
      Mandate.all.each do |mandate|
        mandate.calculate_score
        mandate.save!
      end
    end
  end
end

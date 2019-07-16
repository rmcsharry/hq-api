# frozen_string_literal: true

# Score activities when they get added
module ScoreableActivity
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :contacts, -> { distinct }
    has_and_belongs_to_many :mandates, -> { distinct }

    after_commit do
      puts "AFTER ACTIVITY COMMIT"
    end

    after_add_for_contacts << lambda do |_hook, activity, contact|
      puts "INSIDE AFTER ADD CALLBACK !!!!!!!!!!!!!!!!!"
      puts contact.data_integrity_score
      puts contact.activities.count
      contact.execute_after_related_commit do
        contact.calculate_score && contact.save
      end
      # after_remove_for_contacts << lambda do |_hook, contact, _activity|
      #   binding.pry
      #   rule = get_rule(model_key: 'activities', name: '')
      #   process_single_rule(instance: contact, rule: rule) if contact.activities.count.zero?
      # end
    end
  end

  private

  def one_activity?(object:)
    object.activities.count == 1
  end
end

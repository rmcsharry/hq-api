# frozen_string_literal: true

# Score activities when they get added
module ScoreableActivity
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :contacts, -> { distinct }
    has_and_belongs_to_many :mandates, -> { distinct }

    before_add_for_mandates << lambda do |_hook, _activity, object|
      rule = object.class.get_rule(model_key: 'activities', name: '')
      object.class.process_rule(instance: object, rule: rule, direction: 1) if object.activities.zero?
    end
    before_add_for_contacts << lambda do |_hook, _activity, object|
      rule = object.class.get_rule(model_key: 'activities', name: '')
      object.class.process_rule(instance: object, rule: rule, direction: 1) if object.activities.zero?
    end
    # before_remove_for_contacts << lambda do |_hook, _activity, object|
    #   rule = object.class.get_rule(model_key: 'activities', name: '')
    #   object.class.process_rule(instance: object, rule: rule, direction: -1) if object.activities.count == 1
    # end
  end
end

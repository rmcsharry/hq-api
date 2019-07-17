# frozen_string_literal: true

# Concern to calculate data integrity scores for an entity (eg. person, organisation, mandate)
# including building up the list of attributes that are missing (and thus do not add to the score)
module Scoreable
  extend ActiveSupport::Concern

  class_methods do
    def relative_weights_total
      # memoized at class level since WEIGHT_RULES can only change via code deployment
      @relative_weights_total ||= self::WEIGHT_RULES.sum { |rule| rule[:relative_weight] }.to_f
    end
  end

  included do
    after_commit do
      if @_execute_after_related_commit
        callbacks = @_execute_after_related_commit
        @_execute_after_related_commit = nil
        callbacks.each(&:call)
      end
    end

    before_save :calculate_score, if: :has_changes_to_save?
  end

  def execute_after_related_commit(&callback)
    return unless callback

    # puts "MAIN MODEL execute_after_related_commit"
    @_execute_after_related_commit ||= []
    @_execute_after_related_commit << callback
  end

  # called by an object, for which we will calculate the total score by applying all WEIGHT_RULES defined for its class
  def calculate_score
    processor = WeightRulesProcessor.new(object: self)
    @score = 0
    @score = self.class::WEIGHT_RULES.sum do |rule|
      processor.score(rule: rule)
    end
    self.data_integrity_missing_fields = processor.missing_fields
    assign_score
  end

  def one_activity?
    activities.count == 1
  end

  private

  def assign_score
    self.data_integrity_score = @score
  end
end

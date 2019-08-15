# frozen_string_literal: true

# Concern to calculate data integrity scores for an entity (eg. person, organisation, mandate)
# including building up the list of attributes that are missing (and thus do not add to the score)
module Scoreable
  extend ActiveSupport::Concern

  class_methods do
    def relative_weights_total
      # memoized at class level since SCORE_RULES can only change via code deployment
      @relative_weights_total ||= self::SCORE_RULES.sum { |rule| rule[:relative_weight] }.to_f
    end
  end

  included do
    before_save  :calculate_score
    after_commit :run_after_commit_hooks # hooks created by Activity::Scoreable
  end

  def run_after_commit_hooks
    @already_scored = false
    return unless @_execute_after_commit

    callbacks = @_execute_after_commit
    @_execute_after_commit = nil
    callbacks.each(&:call)
  end

  def execute_after_commit(&callback)
    return unless callback

    @_execute_after_commit ||= []
    @_execute_after_commit << callback
  end

  def rescore
    calculate_score
    @already_scored = true
    save!
  end

  # called by an object, for which we will calculate the total score by applying all SCORE_RULES defined for its class
  def calculate_score
    return if @already_scored

    @score = 0
    missing_fields = []
    @score = self.class::SCORE_RULES.sum do |rule|
      result = Rule.build(object: self, rule: rule)
      missing_fields << result[:name] if result[:score].zero?
      result[:score]
    end
    self.data_integrity_missing_fields = missing_fields
    assign_score
  end

  private

  def assign_score
    self.data_integrity_score = @score
  end
end

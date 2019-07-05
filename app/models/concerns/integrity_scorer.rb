# frozen_string_literal: true

# Concern to calculate data integrity scores for an entity (eg. person, organisation, mandate)
# including building up the list of attributes that are missing (and thus do not add to the score)
module IntegrityScorer
  extend ActiveSupport::Concern

  class_methods do
    def relative_weights_total
      # memoized at class level since WEIGHT_RULES can only change via code deployment
      @relative_weights_total ||= self::WEIGHT_RULES.sum { |rule| rule[:relative_weight] }.to_f
    end
  end

  included do
    before_save :calculate_score, if: :has_changes_to_save?
    after_save :update_mandate_score, if: :owner_score_changed?
  end

  # called by an object, for which we will calculate the total score by applying all WEIGHT_RULES for its class
  def calculate_score
    processor = WeightRulesProcessor.new(object: self)
    @score = 0
    @score = self.class::WEIGHT_RULES.sum do |rule|
      processor.score(rule: rule)
    end
    self.data_integrity_missing_fields = processor.missing_fields
    assign_score
  end

  private

  def assign_score
    self.data_integrity_score = @score
  end

  def owner_score_changed?
    respond_to?(:contact_type) && :saved_change_to_data_integrity_score? && :mandate_owner?
  end

  def update_mandate_score
    # we just updated the score for a contact who is a mandate owner
    # factor that new score into all mandates they own
    mandate_members.where(member_type: 'owner').find_each do |owner|
      owner.mandate.data_integrity_score = owner.mandate.factor_owners_into_score
      owner.mandate.save!
    end
  end
end

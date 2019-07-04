# frozen_string_literal: true

# Concern to calculate data integrity scores for an entity (eg. person, organisation, mandate)
# including building up the list of attributes that are missing (and thus do not add to the score)
module IntegrityScoring
  extend ActiveSupport::Concern

  class_methods do
    def relative_weights_total
      @relative_weights_total ||= self::WEIGHTS.sum { |weight| weight[:relative_weight] }
    end
  end

  included do
    before_save :calculate_score, if: :has_changes_to_save?
  end

  # expects a model instance (ie. one record) which is the entity we will calculate the individual score for
  def calculate_score
    @score = 0
    @missing_fields = []
    @score = self.class::WEIGHTS.sum do |weight|
      @weight = weight
      accumulate_score_by_weight
    end
    assign_result
  end

  private

  def assign_result
    self.data_integrity_missing_fields = @missing_fields
    assign_score
  end

  def assign_score
    self.data_integrity_score = @score
  end

  def accumulate_score_by_weight
    if @weight[:model_key] == model_name.param_key
      from_me # attribute is on the model itself
    else
      from_relative # attribute is on a related model
    end
  end

  def from_me
    field_name = @weight[:name].camelize(:lower)
    if self.class.method_defined? @weight[:name]
      absolute_weight(field_name, :from_method?)
    else
      absolute_weight(field_name, :from_attribute?)
    end
  end

  def from_method?
    public_send(@weight[:name]).present?
  end

  def from_attribute?
    self[@weight[:name]].present?
  end

  def from_relative
    if @weight[:name].include?('==')
      # search_for_field # search the relative for a particular field
      search_for_field
    else
      direct_from_relative # directly check the relative
    end
  end

  def search_for_field
    absolute_weight(@weight[:name].split('==')[0], :related_field_has_value?)
  end

  def related_field_has_value?
    field, value = @weight[:name].split('==')
    public_send(@weight[:model_key]).where("#{field}": value).present?
  end

  def direct_from_relative
    if @weight[:name] == ''
      absolute_weight(@weight[:model_key], :at_least_one_record?)
    else
      absolute_weight(@weight[:name].camelize(:lower), :specific_field?)
    end
  end

  def at_least_one_record?
    public_send(@weight[:model_key]).present?
  end

  def specific_field?
    public_send(@weight[:model_key])[@weight[:name]].present?
  end

  def absolute_weight(field, presence_checker)
    if send(presence_checker)
      # if the value is present, calculate the absolute weight
      @weight[:relative_weight] / self.class.relative_weights_total
    else
      @missing_fields << field
      0
    end
  end
end

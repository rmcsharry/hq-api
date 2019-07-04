# frozen_string_literal: true

# Concern to calculate data integrity scores for an entity (eg. person, organisation, mandate)
# including building up the list of attributes that are missing (and thus do not add to the score)
module IntegrityScoring
  extend ActiveSupport::Concern

  class_methods do
    def relative_weights_total
      # memoized at class level since WEIGHTS can only change via code deployment
      @relative_weights_total ||= self::WEIGHTS.sum { |weight| weight[:relative_weight] }
    end
  end

  included do
    # NOTE: this callback is disabled in tests
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
    return from_me if @weight[:model_key] == model_name.param_key # attribute is on the model itself

    from_relative # attribute is on a related model
  end

  def from_me
    weight_name = @weight[:name]
    field_name = @weight[:name].camelize(:lower)
    if self.class.method_defined?(weight_name)
      absolute_weight(field_name, public_send(weight_name).present?) # apply weight if method returns a value
    else
      absolute_weight(field_name, self[weight_name].present?) # apply weight if attribute returns a value
    end
  end

  def from_relative
    return search_for_field if @weight[:name].include?('==') # search the relative for a particular field

    direct_from_relative # directly check the relative
  end

  def search_for_field
    field, value = @weight[:name].split('==')
    absolute_weight(field, public_send(@weight[:model_key]).where("#{field}": value).present?)
  end

  def direct_from_relative
    weight_name = @weight[:name]
    key = @weight[:model_key]
    if weight_name == ''
      absolute_weight(key, public_send(key).present?) # at least one record for relative
    else
      absolute_weight(weight_name.camelize(:lower), public_send(key)[weight_name].present?) # specific field
    end
  end

  def absolute_weight(field, is_present)
    # if the value is present, calculate the absolute weight
    return @weight[:relative_weight] / self.class.relative_weights_total if is_present

    @missing_fields << field
    0
  end
end

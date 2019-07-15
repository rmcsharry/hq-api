# frozen_string_literal: true

# This class takes an object and given a rule, returns the score for that rule
# The score method checks if the rule is true for the object, returning the score if so
# If the rule does not apply, the missing fields for the object is updated and score returns 0
class WeightRulesProcessor
  attr_reader :missing_fields

  def initialize(object:)
    @object = object
    @missing_fields = []
  end

  def score(rule:)
    @model = rule[:model_key]
    @property = rule[:name]
    @relative_weight = rule[:relative_weight]
    return from_main_model if @model == @object.model_name.param_key # attribute is on the model itself

    from_relative # attribute is on a related model
  end

  private

  def from_main_model
    field_name = @property.camelize(:lower)
    absolute_weight(field_name, :main_property_present?) # apply weight if property returns a value
  end

  def from_relative
    return direct_from_relative if @property.exclude?('==') # directly check the relative

    _, value = @property.split('==')
    absolute_weight(value, :relative_field_value_present?) # search the relative for a particular field value
  end

  def direct_from_relative
    if @property.blank?
      absolute_weight(@model, :relative_at_least_one_present?)
    else
      absolute_weight(@property.camelize(:lower), :relative_specific_property_present?)
    end
  end

  def absolute_weight(missing_name, presence_checker)
    # if the value is present, calculate the absolute weight
    return (@relative_weight / @object.class.relative_weights_total) if send(presence_checker)

    @missing_fields << missing_name
    0.0
  end

  # The following helper methods are the presence checkers passed to the absolute weight calculator
  def main_property_present?
    @object.public_send(@property).present?
  end

  def relative_field_value_present?
    return false if @object.public_send(@model).nil?

    field, value = @property.split('==')
    @object.public_send(@model).where("#{field}": value).present?
  end

  def relative_at_least_one_present?
    return false if @object.public_send(@model).nil?

    @object.public_send(@model).present?
  end

  def relative_specific_property_present?
    return false if @object.public_send(@model).nil?

    @object.public_send(@model)[@property].present?
  end
end

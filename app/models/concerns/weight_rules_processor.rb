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
    return from_model if @model == @object.model_name.param_key # attribute is on the model itself

    from_relative # attribute is on a related model
  end

  private

  def from_model
    field_name = @property.camelize(:lower)
    absolute_weight(field_name, @object.public_send(@property).present?) # apply weight if property returns a value
  end

  def from_relative
    return search_for_field if @property.include?('==') # search the relative for a particular field

    direct_from_relative # directly check the relative
  end

  def search_for_field
    field, value = @property.split('==')
    absolute_weight(value, @object.public_send(@model).where("#{field}": value).present?)
  end

  def direct_from_relative
    if @property.blank?
      absolute_weight(@model, @object.public_send(@model).present?) # at least one record for relative
    else
      absolute_weight(@property.camelize(:lower), @object.public_send(@model)[@property].present?) # specific field
    end
  end

  def absolute_weight(missing_name, is_present)
    # if the value is present, calculate the absolute weight
    return (@relative_weight / @object.class.relative_weights_total) if is_present

    @missing_fields << missing_name
    0.0
  end
end

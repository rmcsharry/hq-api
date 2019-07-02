# frozen_string_literal: true

# Concern to calculate data integrity scores for an entity (eg. person, organisation, mandate)
# including building up the list of attributes that are missing (and thus do not add to the score)
module IntegrityScoring
  extend ActiveSupport::Concern

  included do
    before_save :calculate_score, if: :has_changes_to_save?
  end

  # expects a model instance (ie. one record) which is the entity we will calculate the individual score for
  def calculate_score
    @score = 0
    @missing_fields = []
    @relative_weights_total = self.class::WEIGHTS.map { |weight| weight[:relative_weight] }.reduce(0, :+)

    self.class::WEIGHTS.each do |weight|
      @weight = weight
      accumulate_score_by_weight
    end
    assign_result
  end

  private

  def assign_result
    self.data_integrity_missing_fields = @missing_fields
    if self.class.name == 'Mandate'
      self.data_integrity_partial_score = @score
      self.data_integrity_score = factor_owners_into_score
    else
      self.data_integrity_score = @score
    end
  end

  def factor_owners_into_score
    number_of_owners = 0
    total = @score
    owners.each do |owner|
      number_of_owners += 1
      total += owner.contact.data_integrity_score
    end
    # if no owners, then halve the score, else divide by the number of owners (+1 for the mandate itself)
    number_of_owners.zero? ? total / 2 : total / (number_of_owners + 1)
  end

  def accumulate_score_by_weight
    if @weight[:model_key] == model_name.param_key
      # apply weight when an attribute is on the model itself
      from_me
    else
      # apply weight when attribute is on a related model
      from_relative
    end
  end

  def from_me
    if self[@weight[:name]].present?
      @score += absolute_weight
    else
      @missing_fields << @weight[:name].camelize(:lower)
    end
  end

  def from_relative
    if @weight[:model_key].include?('::')
      search_for_child_type # search the relative for a particular child type of record
    elsif @weight[:name].include?('==')
      search_for_field # search the relative for a particular field
    else
      direct_from_relative # directly check the relative
    end
  end

  def search_for_child_type
    # apply weight from a related child type with many records, but only one of the records should match
    # what we are searching for - eg it is marked primary, such as primary phone
    if child_type_record_present?
      @score += absolute_weight
    else
      # here the missing field is the model key itself (which is the related child type)
      @missing_fields << @weight[:model_key]
    end
  end

  # rubocop:disable Metrics/AbcSize
  def child_type_record_present?
    owner = self.class.name.include?('::') ? self.class.name.split('::')[0].downcase : self.class.name.downcase
    field, value = @weight[:name].split('==')
    model = @weight[:model_key].constantize
    model.where("#{owner}": self, type: @weight[:model_key]).where("#{field}": value).present?
  end
  # rubocop:enable Metrics/AbcSize

  def search_for_field
    # apply weight if the related model has a record that matches the provided search criteria
    field, value = @weight[:name].split('==')
    if public_send(@weight[:model_key]).where("#{field}": value).present?
      @score += absolute_weight
    else
      # here the missing field is a value inside the field and not the field name itself
      @missing_fields << value
    end
  end

  def direct_from_relative
    # if no name provided, then check for at least one record, else check a specific field
    if @weight[:name] == ''
      with_at_least_one_record
    else
      with_specific_field
    end
  end

  def with_at_least_one_record
    # apply weight for a related model if there is at least one record present (eg at least one bank account)
    if public_send(@weight[:model_key]).present?
      @score += absolute_weight
    else
      # here the missing field is the model key itself (since we are just checking it contains a record)
      @missing_fields << @weight[:model_key]
    end
  end

  def with_specific_field
    # apply weight for a specific field of a related model, if that field has a value
    if public_send(@weight[:model_key])[@weight[:name]].present?
      @score += absolute_weight
    else
      @missing_fields << @weight[:name].camelize(:lower)
    end
  end

  def absolute_weight
    @weight[:relative_weight] / @relative_weights_total
  end
end

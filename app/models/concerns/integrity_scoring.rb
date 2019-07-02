# frozen_string_literal: true

# Concern to calculate data integrity scores for an entity (eg. person, organisation, mandate)
# including building up the list of attributes that are missing (and thus do not add to the score)

# rubocop:disable Metrics/ModuleLength
module IntegrityScoring
  extend ActiveSupport::Concern

  included do
    before_save :calculate_score, if: :has_changes_to_save?
  end

  class_methods do
    # expects a class and relalculates scores for all instances of that class
    def calculate_scores
      all.find_each do |object|
        object.calculate_score
        object.save!
      end
    end
  end

  # expects a model instance (ie. one record) which is the entity we will calculate the individual score for
  def calculate_score
    @score = 0
    @missing_fields = []
    # weights = AttributeWeight.where('entity = ?', self.class)
    # @relative_weights_total = weights.sum(&:relative_weight)

    weights = IntegrityWeight::WEIGHTS.collect { |weight| weight if weight[:entity]==self.class.name }.compact
    @relative_weights_total = weights.map { |s| s[:relative_weight] }.reduce(0, :+)

    weights.each do |weight|
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
    if @weight['model_key'.to_sym] == model_name.param_key
      # apply weight when an attribute is on the model itself
      from_me
    else
      # apply weight when attribute is on a related model
      from_relative
    end
  end

  def from_me
    if self[@weight['name'.to_sym]].present?
      @score += (@weight['relative_weight'.to_sym] / @relative_weights_total)
    else
      @missing_fields << @weight['name'.to_sym].camelize(:lower)
    end
  end

  def from_relative
    if @weight['model_key'.to_sym].include?('::')
      search_for_child_type # search the relative for a particular child type of record
    elsif @weight['name'.to_sym].include?('==')
      search_for_field # search the relative for a particular field
    else
      direct_from_relative # directly check the relative
    end
  end

  def search_for_child_type
    # apply weight from a related child type with many records, but only one of the records should match
    # what we are searching for - eg it is marked primary, such as primary phone
    if child_type_record_present?
      @score += (@weight['relative_weight'.to_sym] / @relative_weights_total)
    else
      # here the missing field is the model key itself (which is the related child type)
      @missing_fields << @weight['model_key'.to_sym]
    end
  end

  # rubocop:disable Metrics/AbcSize
  def child_type_record_present?
    owner = @weight.entity.include?('::') ? @weight.entity.split('::')[0].downcase : @weight.entity.downcase
    field, relative_weight = @weight['name'.to_sym].split('==')
    model = @weight['model_key'.to_sym].constantize
    model.where("#{owner}": self, type: @weight['model_key'.to_sym]).where("#{field}": relative_weight).present?
  end
  # rubocop:enable Metrics/AbcSize

  def search_for_field
    # apply weight if the related model has a record that matches the provided search criteria
    field, value = @weight['name'.to_sym].split('==')
    if public_send(@weight['model_key'.to_sym]).where("#{field}": value).present?
      @score += (@weight['relative_weight'.to_sym] / @relative_weights_total)
    else
      # here the missing field is a value inside the field and not the field name itself
      @missing_fields << value
    end
  end

  def direct_from_relative
    # if no name provided, then check for at least one record, else check a specific field
    if @weight['name'.to_sym] == ''
      with_at_least_one_record
    else
      with_specific_field
    end
  end

  def with_at_least_one_record
    # apply weight for a related model if there is at least one record present (eg at least one bank account)
    if public_send(@weight['model_key'.to_sym]).present?
      @score += (@weight['relative_weight'.to_sym] / @relative_weights_total)
    else
      # here the missing field is the model key itself (since we are just checking it contains a record)
      @missing_fields << @weight['model_key'.to_sym]
    end
  end

  def with_specific_field
    # apply weight for a specific field of a related model, if that field has a value
    if public_send(@weight['model_key'.to_sym])[@weight['name'.to_sym]].present?
      @score += (@weight['relative_weight'.to_sym] / @relative_weights_total)
    else
      @missing_fields << @weight['name'.to_sym].camelize(:lower)
    end
  end
end
# rubocop:enable Metrics/ModuleLength

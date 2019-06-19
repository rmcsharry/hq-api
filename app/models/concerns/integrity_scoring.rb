# frozen_string_literal: true

# Concern to calculate data integrity scores for an entity (eg. person, organisation, mandate)
# including building up the list of attributes that are missing (and thus do not add to the score)
module IntegrityScoring
  extend ActiveSupport::Concern

  included do
    before_save :calculate_score, if: :has_changes_to_save?
  end

  # expects a model instance (ie. one record) which is the 'business entity' we are processing
  def calculate_score
    weights = AttributeWeight.where('entity = ?', self.class)
    @score = 0
    @missing_fields = []
    weights.each do |weight|
      @weight = weight
      calculate
    end
    # rubocop:disable Rails/SkipsModelValidations
    update_column(:data_integrity_score, @score)
    update_column(:data_integrity_missing_fields, @missing_fields)
    # rubocop:enable Rails/SkipsModelValidations
  end

  private

  def calculate
    if @weight.model_key == model_name.param_key
      # apply weight when an attribute is on the model itself
      from_me
    else
      # apply weight when attribute is on a related model
      from_relative
    end
  end

  def from_me
    if self[@weight.name].present?
      @score += @weight.value
    else
      @missing_fields << @weight.name.camelize(:lower)
    end
  end

  def from_relative
    # we need to either search the related model for a particular type of record
    # or else check the model related directly
    if @weight.model_key.include?('::')
      nil #search_by_child_type
    elsif @weight.name.include?('==')
      search_related
    else
      direct_from_relative
    end
  end

  # def search_by_child_type
  #   #  apply weight from a related class with many records, but one of the records is primary (eg. primary phone)
  #   if child_type_has_record?
  #     @score += @weight.value
  #   else
  #     @missing_fields << @weight.name
  #   end
  # end

  # def child_type_has_record?
  #   # true
  #   owner = @weight.entity.include?('::') ? @weight.entity.split('::')[0].downcase : @weight.entity.downcase
  #   child = @weight.model_key.constantize
  #   child.where("#{owner}": self, type: @weight.model_key).where(primary: true).present?
  # end

  def search_related
    search_terms = @weight.name.split(',')
    if record_present?(search_terms)
      @score += @weight.value
    else
      # note that we do not camelize this missing field, since it is actually a value inside the attribute
      # and not the attribute name itself
      # if more than one search term, take the first one listed
      @missing_fields << @weight.name.include?(',') ? search_terms[0].split('==')[1] : @weight.name.split('==')[0]
    end
  end

  def record_present?(terms)
    record = public_send(@weight.model_key)
    terms.each do |term|
      field, value = term.split('==')
      record = record.where("#{@weight.model_key}.#{field} = ?", value)
    end
    record.present?
  end

  # def search_relative
  #   term = @weight.name.split(':')[1].to_s
  #   # apply weight if the related model has a record that matches the search
  #   if record_present?(term)
  #     @score += @weight.value
  #   else
  #     # note that we do not camelize this missing field, since it is actually a value inside the attribute
  #     # and not the attribute name itself
  #     @missing_fields << term
  #   end
  # end

  # def record_present?(search_term)
  #   field_to_search = @weight.name.split(':')[0]
  #   public_send(@weight.model_key).where("#{field_to_search} = ?", search_term).present?
  # end

  def direct_from_relative
    # relative either has a record or a specific given property has a value
    if @weight.name == ''
      with_at_least_one_record
    else
      with_specific_property
    end
  end

  def with_at_least_one_record
    # apply weight for a related model if there is at least one record present
    if public_send(@weight.model_key).present?
      @score += @weight.value
    else
      @missing_fields << @weight.model_key
    end
  end

  def with_specific_property
    # apply weight for a specific property of a related model, if that property has a value
    if public_send(@weight.model_key)[@weight.name].present?
      @score += @weight.value
    else
      @missing_fields << @weight.name.camelize(:lower)
    end
  end
end

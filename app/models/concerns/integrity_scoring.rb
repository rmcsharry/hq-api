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
      @missing_fields << @weight.name
    end
  end

  def from_relative
    # we need to either search the related model for a particular type of record
    # or else check the model directly (for at least one record or given property)
    if @weight.name.include?(':')
      search_relative
    else
      direct_from_relative
    end
  end

  def search_relative
    # apply weight if the related model has a record that matches the search
    if record_present?
      @score += @weight.value
    else
      @missing_fields << "#{@weight.model_key}:#{@weight.name}"
    end
  end

  def record_present?
    field_to_search = @weight.name.split(':')[0]
    term = @weight.name.split(':')[1].to_s
    public_send(@weight.model_key).where("#{field_to_search} = ?", term).present?
  end

  def direct_from_relative
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
      @missing_fields << "#{@weight.model_key}:at least one"
    end
  end

  def with_specific_property
    # apply weight for a specific property of a related model, if that property has a value
    if public_send(@weight.model_key)[@weight.name].present?
      @score += @weight.value
    else
      @missing_fields << "#{@weight.model_key}:#{@weight.name}"
    end
  end
end

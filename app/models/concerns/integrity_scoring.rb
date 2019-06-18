# frozen_string_literal: true

# Concern to calculate data integrity scores for an entity (eg. person, organisation, mandate)
module IntegrityScoring
  extend ActiveSupport::Concern

  included do
    before_save :calculate_score, if: :has_changes_to_save?
  end

  # expects a model instance (ie. one record) which is the 'business entity' we are processing
  def calculate_score
    weights = AttributeWeight.where('entity = ?', self.class)
    score = 0
    weights.each do |weight|
      if weight.model_key == model_name.param_key
        # apply weight when an attribute is on the class itself and it has a value
        score += weight.value if self[weight.name].present?
      else
        # apply weight when attribute is on a related class
        score += from_related_model(weight) || 0
      end
    end
    score
  end

  private

  def from_related_model(weight)
    # owner = self.class.name.include?('::') ? self.class.name.split('::')[0].downcase : self.class.name
    if weight.model_key == 'documents'
      document_category(weight)
    elsif weight.model_key == 'mandate_members'
      mandate_member_type(weight)
    elsif weight.model_key.include?('contact_relationships')
      contact_relationship(weight)
    else
      other_model(weight)
    end
  end

  def document_category(weight)
    weight.value if public_send(weight.model_key).where('category = ?', weight.name).present?
  end

  def mandate_member_type(weight)
    weight.value if public_send(weight.model_key).where('member_type = ?', weight.name).present?
  end

  def contact_relationship(weight)
    weight.value if public_send(weight.model_key).where('role = ?', weight.name).present?
  end

  def other_model(weight)
    if weight.name == ''
      # apply weight for a related model if there is at least one record present
      weight.value if public_send(weight.model_key).present?
    elsif public_send(weight.model_key)[weight.name].present?
      # apply weight for a specific property of a related model, if that property has a value
      weight.value
    end
  end

  # def relation_primary(weight, owner)
  #   # apply weight from a related class with many records, but one of the records is primary (eg. primary phone)
  #   weight.value if weight.model_type.constantize.where(
  #     "#{owner}": self, type: weight.model_type, primary: true
  #   ).count.positive?
  # end

  # def relation(weight, owner)
  #   # apply weight from a related class's weight, if the weight has a value
  #   weight.value if weight.model_key.constantize.find_by("#{owner}": self)[weight.name].present?
  # end
end

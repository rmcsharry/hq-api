# frozen_string_literal: true

# == Schema Information
#
# Table name: attribute_weights
#
#  created_at :datetime         not null
#  entity     :string
#  id         :uuid             not null, primary key
#  model_key  :string
#  name       :string
#  updated_at :datetime         not null
#  value      :decimal(5, 2)    default(0.0)
#
# Indexes
#
#  index_attribute_weights_uniqueness  (name,model_key,entity) UNIQUE
#
class AttributeWeight < ApplicationRecord
  # if a weight changes or a new one is added or removed for a given entity,
  # relcalculate the scores for all instances of that entity
  after_commit :calculate_scores

  def calculate_scores
    entity.constantize.calculate_scores
  end
end

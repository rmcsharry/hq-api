# frozen_string_literal: true

# == Schema Information
#
# Table name: attribute_weights
#
#  created_at :datetime         not null
#  entity     :string
#  model_key  :string
#  name       :string
#  updated_at :datetime         not null
#  value      :decimal(5, 4)    default(0.0)
#
# Indexes
#
#  index_attribute_weights_uniqueness  (name,model_key,entity) UNIQUE
#

class AttributeWeight < ApplicationRecord
end

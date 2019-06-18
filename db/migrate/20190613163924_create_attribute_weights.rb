# frozen_string_literal: true

# NOTE: this is a pure standalone lookup table, no id needed
class CreateAttributeWeights < ActiveRecord::Migration[5.2]
  def change
    create_table :attribute_weights, id: false do |t|
      t.string :entity
      t.string :model_key
      t.string :name
      t.decimal :value, precision: 5, scale: 4, default: 0

      t.timestamps

      t.index %i[name model_key entity], unique: true, name: 'index_attribute_weights_uniqueness'
    end
  end
end

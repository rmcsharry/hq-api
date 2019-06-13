class CreateIntegrityWeights < ActiveRecord::Migration[5.2]
  def change
    # note this is a pure standalone lookup table, no primary id needed
    create_table :integrity_weights, id: false do |t|
      t.string :model_name
      t.string :attribute_name
      t.decimal :weight, precision: 3, scale: 2, default: 0

      t.timestamps

      t.index %i[attribute_name model_name], unique: true
    end
  end
end

# Defines the Addresses migration
class CreateAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :addresses do |t|
      t.integer :contact_id
      t.string :street
      t.string :house_number
      t.string :postal_code
      t.string :city
      t.string :country
      t.string :addition

      t.timestamps
    end
  end
end

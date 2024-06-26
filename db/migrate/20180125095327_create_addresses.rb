# Defines the Addresses migration
class CreateAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :addresses, id: :uuid do |t|
      t.uuid :contact_id
      t.string :street
      t.string :house_number
      t.string :postal_code
      t.string :city
      t.string :country
      t.string :addition
      t.string :state

      t.timestamps
    end
  end
end

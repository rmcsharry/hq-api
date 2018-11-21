class AddPlaceOfBirthToContacts < ActiveRecord::Migration[5.2]
  def change
    change_table :contacts do |t|
      t.string :place_of_birth
    end
  end
end

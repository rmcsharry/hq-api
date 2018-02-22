class Address < ApplicationRecord
end

class AddCategoryToAddresses < ActiveRecord::Migration[5.1]
  def change
    add_column :addresses, :category, :string
    add_column :addresses, :street_and_number, :string

    Address.all.each do |address|
      address.update_attributes(street_and_number: "#{address.street} #{address.house_number}")
    end

    remove_column :addresses, :street, :string
    remove_column :addresses, :house_number, :string
  end
end

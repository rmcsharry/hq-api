class AddFieldsToContact < ActiveRecord::Migration[5.1]
  def change
    create_table :compliance_details, id: :uuid do |t|
      t.string :wphg_classification
      t.string :kagb_classification
      t.boolean :politically_exposed, null: false, default: false
      t.string :occupation_role
      t.string :occupation_title
      t.integer :retirement_age

      t.timestamps
    end

    create_table :tax_details, id: :uuid do |t|
      t.string :de_tax_number
      t.string :de_tax_id
      t.string :de_tax_office
      t.boolean :de_retirement_insurance, null: false, default: false
      t.boolean :de_unemployment_insurance, null: false, default: false
      t.boolean :de_health_insurance, null: false, default: false
      t.boolean :de_church_tax, null: false, default: false
      t.string :us_tax_number
      t.string :us_tax_form
      t.string :us_fatca_status
      t.boolean :common_reporting_standard, null: false, default: false
      t.string :eu_vat_number
      t.string :legal_entity_identifier
      t.boolean :transparency_register, null: false, default: false

      t.timestamps
    end

    create_table :foreign_tax_numbers, id: :uuid do |t|
      t.string :tax_number
      t.string :country

      t.timestamps
    end

    change_table :contacts do |t|
      t.remove :email
      t.string :type
      t.text :comment
      t.string :gender
      t.string :nobility_title
      t.string :professional_title
      t.string :maiden_name
      t.date :date_of_birth
      t.date :date_of_death
      t.string :nationality
      t.string :organization_name
      t.string :organization_type
      t.string :organization_category
      t.string :organization_industry
      t.string :commercial_register_number
      t.string :commercial_register_office
    end

    add_reference :contacts, :legal_address, index: true, type: :uuid
    add_foreign_key :contacts, :addresses, column: :legal_address_id

    add_reference :contacts, :primary_contact_address, index: true, type: :uuid
    add_foreign_key :contacts, :addresses, column: :primary_contact_address_id

    add_reference :compliance_details, :contact, foreign_key: true, type: :uuid
    add_reference :tax_details, :contact, foreign_key: true, type: :uuid
    add_reference :foreign_tax_numbers, :tax_detail, foreign_key: true, type: :uuid
  end
end

# Defines the Investor creation migration
class CreateInvestorModel < ActiveRecord::Migration[5.2]
  def change
    create_table :investors, id: :uuid do |t|
      t.belongs_to :fund, index: true, foreign_key: { to_table: :funds }, type: :uuid
      t.belongs_to :mandate, index: true, foreign_key: { to_table: :mandates }, type: :uuid
      t.belongs_to :legal_address, index: false, foreign_key: { to_table: :addresses }, type: :uuid
      t.belongs_to :contact_address, index: false, foreign_key: { to_table: :addresses }, type: :uuid
      t.belongs_to :contact_email, index: false, foreign_key: { to_table: :contact_details }, type: :uuid
      t.belongs_to :contact_phone, index: false, foreign_key: { to_table: :contact_details }, type: :uuid
      t.belongs_to :bank_account, index: false, foreign_key: { to_table: :bank_accounts }, type: :uuid
      t.belongs_to :primary_owner, index: false, foreign_key: { to_table: :contacts }, type: :uuid

      t.string :aasm_state, null: false
      t.datetime :investment_date
      t.decimal :amount_total, :decimal, precision: 20, scale: 2

      t.timestamps
    end
  end
end

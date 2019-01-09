class CreateFundCashflows < ActiveRecord::Migration[5.2]
  def change
    create_table :fund_cashflows, id: :uuid do |t|
      t.integer :number
      t.date :valuta_date

      t.belongs_to :fund, index: true, foreign_key: true, type: :uuid

      t.timestamps
    end

    create_table :investor_cashflows, id: :uuid do |t|
      t.string :aasm_state
      t.decimal :distribution_reduction_amount, precision: 20, scale: 10, default: 0, null: false
      t.decimal :distribution_participation_profits_amount, precision: 20, scale: 10, default: 0, null: false
      t.decimal :distribution_dividends_amount, precision: 20, scale: 10, default: 0, null: false
      t.decimal :distribution_interest_amount, precision: 20, scale: 10, default: 0, null: false
      t.decimal :distribution_misc_profits_amount, precision: 20, scale: 10, default: 0, null: false
      t.decimal :distribution_structure_costs_amount, precision: 20, scale: 10, default: 0, null: false
      t.decimal :distribution_withholding_tax_amount, precision: 20, scale: 10, default: 0, null: false
      t.decimal :distribution_recallable_amount, precision: 20, scale: 10, default: 0, null: false
      t.decimal :distribution_compensatory_interest_amount, precision: 20, scale: 10, default: 0, null: false
      t.decimal :capital_call_gross_amount, precision: 20, scale: 10, default: 0, null: false
      t.decimal :capital_call_compensatory_interest_amount, precision: 20, scale: 10, default: 0, null: false
      t.decimal :capital_call_management_fees_amount, precision: 20, scale: 10, default: 0, null: false

      t.belongs_to :fund_cashflow, index: true, foreign_key: true, type: :uuid
      t.belongs_to :investor, index: true, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end

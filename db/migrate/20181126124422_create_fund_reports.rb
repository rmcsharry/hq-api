class CreateFundReports < ActiveRecord::Migration[5.2]
  def change
    create_table :fund_reports, id: :uuid do |t|
      t.date :valuta_date
      t.decimal :irr, precision: 20, scale: 10
      t.text :description

      t.belongs_to :fund, index: true, foreign_key: { to_table: :funds }, type: :uuid

      t.timestamps
    end

    create_table :fund_reports_investors, id: false do |t|
      t.belongs_to :fund_report, index: true, foreign_key: true, type: :uuid
      t.belongs_to :investor, index: true, foreign_key: true, type: :uuid
    end
  end
end

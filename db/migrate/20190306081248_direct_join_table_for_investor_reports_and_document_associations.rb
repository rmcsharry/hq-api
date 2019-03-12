class DirectJoinTableForInvestorReportsAndDocumentAssociations < ActiveRecord::Migration[5.2]
  def change
    rename_table :fund_reports_investors, :investor_reports
    add_column :investor_reports, :id, :uuid, default: 'gen_random_uuid()', null: false, index: true
    execute 'ALTER TABLE investor_reports ADD PRIMARY KEY (id);'
  end
end

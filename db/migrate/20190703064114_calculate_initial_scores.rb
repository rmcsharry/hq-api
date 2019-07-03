class CalculateInitialScores < ActiveRecord::Migration[5.2]
  def up
    Rake::Task['db:calculate_scores'].invoke
  end

  def down
    AttributeWeight.delete_all
    Contact.update_all(data_integrity_score: 0)
    Contact.update_all(data_integrity_missing_fields: [])
    Mandate.update_all(data_integrity_score: 0)
    Mandate.update_all(data_integrity_partial_score: 0)
    Mandate.update_all(data_integrity_missing_fields: [])
  end
end

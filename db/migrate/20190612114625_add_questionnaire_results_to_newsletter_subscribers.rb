class AddQuestionnaireResultsToNewsletterSubscribers < ActiveRecord::Migration[5.2]
  def change
    add_column :newsletter_subscribers, :questionnaire_results, :jsonb
  end
end

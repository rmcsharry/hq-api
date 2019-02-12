class CreateNewsletterSubscribers < ActiveRecord::Migration[5.2]
  def change
    create_table :newsletter_subscribers, id: :uuid do |t|
      t.string :email, null: false
      t.string :first_name
      t.string :last_name
      t.string :gender
      t.string :professional_title
      t.string :nobility_title
      t.string :confirmation_token
      t.string :mailjet_list_id
      t.string :confirmation_base_url
      t.string :confirmation_success_url
      t.string :aasm_state
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at

      t.timestamps
    end
  end
end

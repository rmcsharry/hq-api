class AddContextToNewsletterSubscribers < ActiveRecord::Migration[5.2]
  def change
    add_column :newsletter_subscribers, :subscriber_context, :string, null: false, default: 'hqt'
  end
end

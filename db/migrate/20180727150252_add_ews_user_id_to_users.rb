class AddEWSUserIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :ews_user_id, :string
  end
end

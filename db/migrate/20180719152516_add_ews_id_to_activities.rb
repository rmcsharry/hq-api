class AddEWSIdToActivities < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :ews_id, :string
  end
end

class RemoveMandateMemberValidityRange < ActiveRecord::Migration[5.2]
  def change
    remove_column :mandate_members, :start_date
    remove_column :mandate_members, :end_date
  end
end

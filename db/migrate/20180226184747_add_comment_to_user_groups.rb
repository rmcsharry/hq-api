class AddCommentToUserGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :user_groups, :comment, :text
  end
end

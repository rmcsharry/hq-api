class AddCommentToContactRelationshipsAndMandateMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :contact_relationships, :comment, :text
    add_column :mandate_members, :comment, :text
  end
end

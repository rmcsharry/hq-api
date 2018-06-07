class AddUniquenessConstraintToJoinTables < ActiveRecord::Migration[5.2]
  def change
    add_index(
      :mandate_groups_mandates,
      [ :mandate_group_id, :mandate_id ],
      unique: true,
      name: 'by_mandate_group_and_mandate'
    )

    add_index(
      :mandate_groups_user_groups,
      [ :mandate_group_id, :user_group_id ],
      unique: true,
      name: 'by_mandate_group_and_user_group'
    )

    add_index(
      :user_groups_users,
      [ :user_group_id, :user_id ],
      unique: true,
      name: 'by_user_group_and_user'
    )

    add_index(
      :activities_contacts,
      [ :activity_id, :contact_id ],
      unique: true,
      name: 'by_activity_and_contact'
    )

    add_index(
      :activities_mandates,
      [ :activity_id, :mandate_id ],
      unique: true,
      name: 'by_activity_and_mandate'
    )
  end
end

class DropTablesForContactRelationships < ActiveRecord::Migration[5.2]
  def change
    drop_table :organization_members
    drop_table :inter_person_relationships
  end
end

class RemoveObsoleteMandateContactRelationships < ActiveRecord::Migration[5.2]
  def change
    ActiveRecord::Base.transaction do
      Mandate.find_in_batches do |batch|
        batch.each do |mandate|
          previous_mm_count = mandate.mandate_members.count
          legacy_relation_count = 0

          if mandate.primary_consultant.present?
            legacy_relation_count += 1
            MandateMember.create(
              contact: mandate.primary_consultant,
              mandate: mandate,
              member_type: :primary_consultant
            )
          end

          if mandate.secondary_consultant.present?
            legacy_relation_count += 1
            MandateMember.create(
              contact: mandate.secondary_consultant,
              mandate: mandate,
              member_type: :secondary_consultant
            )
          end

          if mandate.bookkeeper.present?
            legacy_relation_count += 1
            MandateMember.create(
              contact: mandate.bookkeeper,
              mandate: mandate,
              member_type: :bookkeeper
            )
          end

          if mandate.assistant.present?
            legacy_relation_count += 1
            MandateMember.create(
              contact: mandate.assistant,
              mandate: mandate,
              member_type: :assistant
            )
          end

          new_mm_count = mandate.mandate_members.count
          if new_mm_count != previous_mm_count + legacy_relation_count
            raise ActiveRecord::ActiveRecordError
          end
        end
      end
    end

    remove_column :mandates, :primary_consultant_id
    remove_column :mandates, :secondary_consultant_id
    remove_column :mandates, :assistant_id
    remove_column :mandates, :bookkeeper_id
  end
end

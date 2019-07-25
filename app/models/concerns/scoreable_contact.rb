# frozen_string_literal: true


# Shared logic for scoring contacts
module ScoreableContact
  extend ActiveSupport::Concern

  included do
    after_save :update_mandate_score, if: :owner_score_changed?
  end

  def owner_score_changed?
    :saved_change_to_data_integrity_score? && :mandate_owner?
  end

  # If we just updated the score for a contact who is a mandate owner
  # we now must factor that new score into all mandates they own
  def update_mandate_score
    Mandate.skip_callback(:save, :before, :calculate_score, raise: false)
    mandate_members.where(member_type: 'owner').find_each do |owner|
      owner.mandate.data_integrity_score = owner.mandate.factor_owners_into_score
      owner.mandate.save!
    end
    Mandate.set_callback(:save, :before, :calculate_score, if: :has_changes_to_save?)
  end
end

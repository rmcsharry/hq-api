# frozen_string_literal: true

# Concern to calculate data integrity scores for a mandate
module ScoreableMandate
  extend ActiveSupport::Concern

  included do
    after_save :update_mandate_score, if: :owner_score_changed?
  end

  WEIGHT_RULES = [
    { model_key: 'activities', name: '', relative_weight: 17 },
    { model_key: 'bank_accounts', name: '', relative_weight: 5 },
    { model_key: 'documents', name: 'category==contract_hq', relative_weight: 15 },
    { model_key: 'mandate', name: 'category', relative_weight: 5 },
    { model_key: 'mandate', name: 'datev_creditor_id', relative_weight: 1 },
    { model_key: 'mandate', name: 'datev_debitor_id', relative_weight: 1 },
    { model_key: 'mandate', name: 'mandate_number', relative_weight: 1 },
    { model_key: 'mandate', name: 'psplus_id', relative_weight: 1 },
    { model_key: 'mandate', name: 'state', relative_weight: 5 },
    { model_key: 'mandate', name: 'valid_from', relative_weight: 1 },
    { model_key: 'mandate_members', name: 'member_type==assistant', relative_weight: 5 },
    { model_key: 'mandate_members', name: 'member_type==bookkeeper', relative_weight: 5 },
    { model_key: 'mandate_members', name: 'member_type==owner', relative_weight: 5 },
    { model_key: 'mandate_members', name: 'member_type==primary_consultant', relative_weight: 5 },
    { model_key: 'mandate_members', name: 'member_type==secondary_consultant', relative_weight: 5 }
  ].freeze

  def factor_owners_into_score
    # if no owners, then halve the score, else divide by the number of owners (+1 for the mandate itself)
    count = owners.count # NOTE: don't move this to the ternary below or you will get two DB reads
    total = (data_integrity_partial_score + owners.sum { |owner| owner.contact.data_integrity_score })
    total / (count.zero? ? 2 : count + 1).to_f
  end

  private

  # After integrity scoring calculation runs, assign the newly calculated score and factor owners in
  def assign_score
    self.data_integrity_partial_score = @score
    self.data_integrity_score = factor_owners_into_score
  end

  def owner_score_changed?
    :saved_change_to_data_integrity_score? && :mandate_owner?
  end

  # We just updated the score for a contact who is a mandate owner
  # so now we must factor that new score into all mandates they own
  def update_mandate_score
    mandate_members.where(member_type: 'owner').find_each do |owner|
      owner.mandate.data_integrity_score = owner.mandate.factor_owners_into_score
      owner.mandate.save!
    end
  end
end

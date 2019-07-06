# frozen_string_literal: true

# Concern to provide weight inputs to calculate data integrity scores for a mandate
module WeightRulesMandate
  extend ActiveSupport::Concern

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
end

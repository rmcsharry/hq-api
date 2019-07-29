# frozen_string_literal: true

module Scoreable
  # Score related objects (contact/mandate) when a document of a given type
  # is FIRST ADDED TO or FINALLY REMOVED FROM the related objects
  module Document
    extend ActiveSupport::Concern

    included do
      # after_commit :rescore
    end

    def rescore
      return unless score_impacted? # no need to recalculate owner score if document does not match the score rule

      owner.class.skip_callback(:save, :before, :calculate_score, raise: false)
      puts 'RESCORE !!!!!!!!!!!!!!!!!!!'
      # NOTE if owner is a mandate, then this calculate_score will also trigger calling factor_owners_into_score
      owner.calculate_score if owner_type == 'Contact' || owner_type == 'Mandate'
      owner.save!
      owner.class.set_callback(:save, :before, :calculate_score, if: :has_changes_to_save?)
    end

    def score_impacted?
      true
      # did we save changes that relate to the documents rule for the owner?
      # rule = owner.class::SCORE_RULES.select { |r| r[:model_key] == 'documents' }[0]
      # field, value = rule[:name].split('==')
      # changes = saved_changes[field]
      # puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! #{changes}"
      # changes&.select { |change| change == value }&.any?
    end
  end
end

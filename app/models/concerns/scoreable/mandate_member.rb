# frozen_string_literal: true

module Scoreable
  # Concern to provide scoring rules and logic for a mandate
  module MandateMember
    extend ActiveSupport::Concern

    included do
      after_commit :rescore
    end

    def rescore
      Bullet.enable = false
      mandate.calculate_score
      mandate.save!
      Bullet.enable = true
    end
  end
end

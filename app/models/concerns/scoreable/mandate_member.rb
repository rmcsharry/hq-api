# frozen_string_literal: true

module Scoreable
  # Rescore a mandate when members change
  module MandateMember
    extend ActiveSupport::Concern

    included do
      after_commit :rescore_mandate
    end

    def rescore_mandate
      Bullet.enable = false
      mandate.rescore
      Bullet.enable = true
    end
  end
end

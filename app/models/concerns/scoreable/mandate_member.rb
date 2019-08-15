# frozen_string_literal: true

module Scoreable
  # Score a mandate when its members change
  module MandateMember
    extend ActiveSupport::Concern

    included do
      after_commit :rescore_mandate
    end

    def rescore_mandate
      mandate.rescore
    end
  end
end

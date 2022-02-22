# frozen_string_literal: true

module Scoreable
  # Score related objects (contact/mandate) when a compliance detail changes
  module DetailBase
    extend ActiveSupport::Concern

    included do
      after_commit :rescore_contact
    end

    def rescore_contact
      contact.rescore
    end
  end
end

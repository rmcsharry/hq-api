# frozen_string_literal: true

module V1
  module Shoulda
    module Matchers
      module ActiveRecord
        module Uniqueness
          module TestModels
            class ContacuResource
              # Stub to fix this issue: https://github.com/HQTrust/hqtrust-core-api/pull/318
              def self._model_class
                Contact
              end
            end
          end
        end
      end
    end
  end
end

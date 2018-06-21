# frozen_string_literal: true

def permit(*permitted_roles, &block)
  forbidden_roles = UserGroup::AVAILABLE_ROLES - permitted_roles
  include_examples 'authorization policy', forbidden_roles, permitted: false
  include_examples 'authorization policy', permitted_roles, permitted: true, expectation: block
end

def permit_all(&block)
  include_examples 'authorization policy', UserGroup::AVAILABLE_ROLES, permitted: true, expectation: block
end

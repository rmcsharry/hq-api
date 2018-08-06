# frozen_string_literal: true

# Handles token decoding and role extraction and acts as superclass
# for both, policies and policy-scopes
class PolicyWithRoles
  attr_reader :request, :roles, :user

  def initialize(user_context)
    @request = user_context.request
    auth_header = @request.headers['HTTP_AUTHORIZATION']
    return if auth_header.blank? || !auth_header.start_with?('Bearer ')
    token_payload = decode(auth_header)
    @roles = token_payload['roles']
    @user  = user_context.user
  end

  def decode(auth_header)
    token = auth_header.split(' ').last
    Warden::JWTAuth::TokenDecoder.new.call(token)
  end

  def request_attribute(*nested_attributes)
    request.params.dig 'data', 'attributes', *nested_attributes
  end

  def role?(*args)
    args.any? { |role| roles.include? role.to_s }
  end

  def conditional_role?(role, record: {}, request: {})
    role?(role) &&
      record_conditions_fulfilled?(record) &&
      (relationship_update? || request_conditions_fulfilled?(request))
  end

  def request_conditions_fulfilled?(request_conditions)
    request_conditions.all? do |key, value|
      if value.is_a?(Array)
        value.any? { |val| request_attribute(key) == val }
      else
        request_attribute(key) == value
      end
    end
  end

  def record_conditions_fulfilled?(record_conditions)
    record_conditions.all? do |key, value|
      record.send(key) == value
    end
  end

  def relationship_update?
    request.params.dig('relationship').present?
  end
end

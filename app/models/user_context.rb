# frozen_string_literal: true

# Extended user that is being passed to pundit roles and scopes to provide
# additional context necessary for sophisticated authorization rules
class UserContext
  attr_reader :user, :request

  def initialize(user, request)
    @user = user
    @request = request
  end
end

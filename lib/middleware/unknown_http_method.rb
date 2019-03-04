# frozen_string_literal: true

module Middleware
  # Defines a middleware for rescuing requests with unknown http methods
  class UnknownHttpMethod
    def initialize(app)
      @app = app
    end

    def call(env)
      if !ActionDispatch::Request::HTTP_METHODS.include?(env['REQUEST_METHOD'].upcase)
        Rails.logger.info("ActionController::UnknownHttpMethod: #{env.inspect}")
        [405, { 'Content-Type' => 'text/plain' }, ['Method Not Allowed']]
      else
        @status, @headers, @response = @app.call(env)
        [@status, @headers, @response]
      end
    end
  end
end

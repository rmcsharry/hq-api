# frozen_string_literal: true

# Healthcheck of the application
class HealthcheckController < ApplicationController
  def health
    render json: { ok: true, test: 'new2' }
  end
end

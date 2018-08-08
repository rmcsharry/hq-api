# frozen_string_literal: true

# Healthcheck of the application
class HealthcheckController < ApplicationController
  def health
    render json: { ok: true }
  end
end

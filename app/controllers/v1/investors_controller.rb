# frozen_string_literal: true

module V1
  # Defines the Investors controller
  class InvestorsController < ApplicationController
    include FileSender

    before_action :authenticate_user!

    def fund_subscription_agreement_document
      investor = Investor.find(params.require(:id))
      authorize investor, :show?

      send_attachment(
        investor.subscription_agreement_document(current_user).file
      )
    end
  end
end

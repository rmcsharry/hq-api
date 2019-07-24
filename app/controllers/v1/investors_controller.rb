# frozen_string_literal: true

module V1
  # Defines the Investors controller
  class InvestorsController < ApplicationController
    include FileSender

    before_action :authenticate_user!

    def fund_subscription_agreement_document
      download_subscription_agreement_document
    end

    def regenerated_fund_subscription_agreement_document
      download_subscription_agreement_document(regenerate: true)
    end

    private

    def download_subscription_agreement_document(regenerate: false)
      send_attachment(
        accessible_investor.subscription_agreement_document(
          current_user: current_user, regenerate: regenerate
        ).file
      )
    end

    def accessible_investor
      investor = Investor.find(params.require(:id))
      investor if authorize investor, :show?
    end
  end
end

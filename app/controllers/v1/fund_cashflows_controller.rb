# frozen_string_literal: true

module V1
  # Defines the FundCashflows controller
  class FundCashflowsController < ApplicationController
    include FileSender

    before_action :authenticate_user!

    def update
      FundCashflow.transaction do
        super
      end
    end

    def archived_documents
      download_documents
    end

    def regenerated_documents
      download_documents(regenerate: true)
    end

    private

    def download_documents(regenerate: false)
      fund_cashflow = FundCashflow
                      .includes(investor_cashflows: { investor: [mandate: :contact_address], fund_cashflow: :fund })
                      .find(params.require(:id))
      authorize fund_cashflow, :show?

      send_archive(
        cashflow_document_map(fund_cashflow: fund_cashflow, regenerate: regenerate),
        fund_cashflow.archive_name
      )
    end

    def cashflow_document_map(fund_cashflow:, regenerate: false)
      fund_cashflow.investor_cashflows.each_with_object({}) do |investor_cashflow, documents|
        file = investor_cashflow.cashflow_document(current_user: current_user, regenerate: regenerate).file
        documents[file.filename] = file.download
      end
    end
  end
end

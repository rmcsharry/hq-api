# frozen_string_literal: true

module V1
  # Defines the FundCashflows controller
  class FundCashflowsController < ApplicationController
    include FileSender

    before_action :authenticate_user!

    def archived_documents
      fund_cashflow = FundCashflow
                      .includes(investor_cashflows: { investor: %i[contact_address mandate], fund_cashflow: :fund })
                      .find(params.require(:id))
      authorize fund_cashflow, :show?

      send_archive cashflow_document_map(fund_cashflow), fund_cashflow.archive_name
    end

    private

    def cashflow_document_map(fund_cashflow)
      fund_cashflow.investor_cashflows.each_with_object({}) do |investor_cashflow, documents|
        file = investor_cashflow.cashflow_document(current_user).file
        documents[file.filename] = file.download
      end
    end
  end
end

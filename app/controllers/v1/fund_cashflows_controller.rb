# frozen_string_literal: true

module V1
  # Defines the FundCashflows controller
  class FundCashflowsController < ApplicationController
    include DocumentBuilder

    before_action :authenticate_user!

    def archived_documents
      fund_cashflow = FundCashflow
                      .includes(investor_cashflows: { investor: %i[contact_address mandate], fund_cashflow: :fund })
                      .find(params.require(:id))
      authorize fund_cashflow, :show?

      send_archive build_documents(fund_cashflow)
    end

    private

    def build_documents(fund_cashflow)
      template = fund_cashflow.fund.cashflow_template(fund_cashflow)

      fund_cashflow.investor_cashflows.each_with_object({}) do |investor_cashflow, documents|
        context = investor_cashflow.document_context
        name = document_name(fund_cashflow, investor_cashflow)
        documents[name] = build_document(template, context)
      end
    end

    def document_name(fund_cashflow, investor_cashflow)
      mandate = investor_cashflow.investor.mandate.decorate
      mandate_identifier = mandate.owner_name
      fund_identifier = fund_cashflow.fund.name
      cashflow_number = fund_cashflow.number
      cashflow_type = cashflow_type == :capital_call ? 'Kapitalabruf' : 'Ausschüttung'
      "Anschreiben_#{cashflow_type}_#{cashflow_number}_#{fund_identifier}_#{mandate_identifier}.docx"
    end
  end
end

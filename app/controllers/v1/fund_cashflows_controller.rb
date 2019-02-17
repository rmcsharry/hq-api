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

      send_file build_document_archive(fund_cashflow), 'application/zip'
    end

    private

    def build_document_archive(fund_cashflow)
      template = fund_cashflow.fund.cashflow_template(fund_cashflow)

      Zip::OutputStream.write_buffer do |out|
        fund_cashflow.investor_cashflows.each do |investor_cashflow|
          context = investor_cashflow.document_context
          out.put_next_entry(document_name(fund_cashflow, investor_cashflow))
          out.write(build_document(template, context))
        end
      end.string
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

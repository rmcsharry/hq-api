# frozen_string_literal: true

module V1
  # Defines the InvestorCashflows controller
  class InvestorCashflowsController < ApplicationController
    include DocumentBuilder

    before_action :authenticate_user!

    def finish
      begin
        @response_document = create_response_document
        investor_cashflow = InvestorCashflow.find params[:id]
        authorize investor_cashflow, :update?
        investor_cashflow.finish!
        generate_investor_cashflow_response(investor_cashflow: investor_cashflow)
      rescue JSONAPI::Exceptions::Error => e
        handle_exceptions(e)
      end
      render_response_document
    end

    def filled_fund_template
      investor_cashflow = InvestorCashflow
                          .includes(investor: :contact_address, fund_cashflow: :fund)
                          .find(params.require(:id))
      authorize investor_cashflow, :show?

      template = investor_cashflow.investor.fund.cashflow_template(investor_cashflow.fund_cashflow)
      context = investor_cashflow.document_context
      send_filled_template(template, context)
    end

    private

    def generate_investor_cashflow_response(
        investor_cashflow:, serializer: JSONAPI::ResourceSerializer.new(InvestorCashflowResource)
      )
      resource_set = create_resource_set(investor_cashflow: investor_cashflow)
      result = JSONAPI::ResourceSetOperationResult.new(:ok, resource_set)
      operation = JSONAPI::Operation.new(
        :show,
        InvestorCashflowResource,
        serializer: serializer
      )
      response_document.add_result(result, operation)
    end

    def create_resource_set(investor_cashflow:)
      {
        'InvestorCashflowResource' => {
          investor_cashflow.id => {
            primary: true,
            resource: InvestorCashflowResource.new(investor_cashflow, nil),
            relationships: {}
          }
        }
      }
    end
  end
end

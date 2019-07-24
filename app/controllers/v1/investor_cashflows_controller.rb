# frozen_string_literal: true

module V1
  # Defines the InvestorCashflows controller
  class InvestorCashflowsController < ApplicationController
    include FileSender

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

    def cashflow_document
      download_cashflow_document
    end

    def regenerated_cashflow_document
      download_cashflow_document(regenerate: true)
    end

    private

    def download_cashflow_document(regenerate: false)
      investor_cashflow = InvestorCashflow
                          .includes(:documents, investor: :contact_address, fund_cashflow: :fund)
                          .find(params.require(:id))
      authorize investor_cashflow, :show?

      send_attachment(
        investor_cashflow.cashflow_document(current_user: current_user, regenerate: regenerate).file
      )
    end

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

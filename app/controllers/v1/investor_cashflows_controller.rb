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

    # rubocop:disable Metrics/MethodLength
    def filled_fund_template
      investor_cashflow = InvestorCashflow
                          .includes(investor: :contact_address, fund_cashflow: :fund)
                          .find(params.require(:id))
      authorize investor_cashflow, :show?

      cashflow_type = investor_cashflow.fund_cashflow.fund_cashflow_type

      if cashflow_type == :capital_call
        template = fund_template(investor_cashflow, :fund_capital_call_template)
        context = fund_capital_call_context(investor_cashflow)
      else
        template = fund_template(investor_cashflow, :fund_distribution_template)
        context = fund_distribution_context(investor_cashflow)
      end

      render_filled_template(template, context)
    end
    # rubocop:enable Metrics/MethodLength

    private

    def fund_template(investor_cashflow, template_category)
      Document.find_by(
        owner_id: investor_cashflow.fund_cashflow.fund_id,
        category: template_category
      )
    end

    def fund_distribution_context(investor_cashflow)
      Document::FundTemplate.fund_distribution_context(
        investor_cashflow: investor_cashflow
      )
    end

    def fund_capital_call_context(investor_cashflow)
      Document::FundTemplate.fund_capital_call_context(
        investor_cashflow: investor_cashflow
      )
    end
  end
end

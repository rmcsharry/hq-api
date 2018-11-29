# frozen_string_literal: true

module V1
  # Defines the Investor resource for the API
  class InvestorResource < BaseResource
    attributes(
      :amount_called,
      :amount_open,
      :amount_total,
      :amount_total_distribution,
      :current_value,
      :dpi,
      :investment_date,
      :irr,
      :state,
      :tvpi,
      :updated_at
    )

    has_one :bank_account
    has_one :contact_address, class_name: 'Address'
    has_one :contact_email, class_name: 'ContactDetail'
    has_one :contact_phone, class_name: 'ContactDetail'
    has_one :fund
    has_one :fund_subscription_agreement, class_name: 'Document'
    has_one :legal_address, class_name: 'Address'
    has_one :mandate
    has_one :primary_owner, class_name: 'Contact'

    has_many :documents

    filters(
      :fund_id,
      :mandate_id
    )

    filter :fund_report_id, apply: lambda { |records, value, _options|
      records.joins(:fund_reports).where('fund_reports.id = ?', value[0])
    }

    class << self
      def updatable_fields(context)
        super(context) - %i[
          amount_called
          amount_open
          amount_total_distribution
          current_value
          dpi
          irr
          tvpi
        ]
      end
    end
  end
end

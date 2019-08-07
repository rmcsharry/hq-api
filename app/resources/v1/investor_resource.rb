# frozen_string_literal: true

module V1
  # Defines the Investor resource for the API
  class InvestorResource < BaseResource
    attributes(
      :amount_called,
      :amount_open,
      :amount_total,
      :amount_total_distribution,
      :capital_account_number,
      :contact_salutation_primary_contact,
      :contact_salutation_primary_owner,
      :contact_salutation_secondary_contact,
      :created_at,
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
    has_one :fund
    has_one :fund_subscription_agreement, class_name: 'Document'
    has_one :legal_address, class_name: 'Address'
    has_one :mandate
    has_one :primary_contact, class_name: 'Contact'
    has_one :primary_owner, class_name: 'Contact'
    has_one :secondary_contact, class_name: 'Contact'

    has_many :documents
    has_many :investor_reports

    filters(
      :fund_id,
      :mandate_id,
      :state
    )

    filter :fund_report_id, apply: lambda { |records, value, _options|
      records.joins(:fund_reports).where('fund_reports.id = ?', value[0])
    }

    sort :"mandate.owner_name", apply: lambda { |records, direction, _context|
      Mandate
        .with_owner_name
        .joins(:investments)
        .merge(records)
        .order("mandates.owner_name #{direction}")
    }

    sort :"fund.state", apply: lambda { |records, direction, _context|
      records.joins(:fund).order("funds.aasm_state #{direction}")
    }

    sort :"fund.name", apply: lambda { |records, direction, _context|
      records.joins(:fund).order("funds.name #{direction}")
    }

    class << self
      # rubocop:disable Metrics/MethodLength
      def updatable_fields(context)
        super(context) - %i[
          amount_called
          amount_open
          amount_total_distribution
          contact_address
          contact_salutation_primary_contact
          contact_salutation_primary_owner
          contact_salutation_secondary_contact
          current_value
          dpi
          irr
          legal_address
          primary_contact
          primary_owner
          secondary_contact
          tvpi
        ]
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end

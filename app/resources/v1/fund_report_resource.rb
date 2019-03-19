# frozen_string_literal: true

module V1
  # Defines the FundReport resource for the API
  class FundReportResource < BaseResource
    attributes(
      :description,
      :investor_count,
      :irr,
      :valuta_date
    )

    has_one :fund

    has_many :investor_reports

    filter :fund_id

    sort :investor_count, apply: lambda { |records, direction, _context|
      records.left_joins(:investors).group(:id).order("COUNT(investors.id) #{direction}")
    }

    def investor_count
      @model.investors.count
    end

    class << self
      def updatable_fields(context)
        super(context) - %i[investor_count]
      end
    end
  end
end

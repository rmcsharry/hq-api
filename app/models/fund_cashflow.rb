# frozen_string_literal: true

# == Schema Information
#
# Table name: fund_cashflows
#
#  created_at  :datetime         not null
#  fund_id     :uuid
#  id          :uuid             not null, primary key
#  number      :integer
#  updated_at  :datetime         not null
#  valuta_date :date
#
# Indexes
#
#  index_fund_cashflows_on_fund_id  (fund_id)
#
# Foreign Keys
#
#  fk_rails_...  (fund_id => funds.id)
#

# Defines the FundCashflow
class FundCashflow < ApplicationRecord
  belongs_to :fund, autosave: true, optional: false
  has_many :investor_cashflows, dependent: :destroy

  has_paper_trail(
    meta: {
      parent_item_id: :fund_id,
      parent_item_type: 'Fund'
    },
    skip: SKIPPED_ATTRIBUTES
  )

  validates :number, presence: true, uniqueness: { scope: :fund_id, message: 'should occur only once per fund' }
  validates :valuta_date, presence: true

  before_validation :assign_number, on: :create

  # rubocop:disable Metrics/BlockLength
  scope :with_net_cashflow_amount, lambda {
    from(
      "
        (
          SELECT fc.*, agg_fc.net_cashflow_amount
          FROM fund_cashflows fc
          LEFT JOIN (
            SELECT fund_cashflow_id AS fund_cashflow_id,
              (
                SUM(investor_cashflows.distribution_repatriation_amount) +
                SUM(distribution_participation_profits_amount) +
                SUM(distribution_dividends_amount) +
                SUM(distribution_interest_amount) +
                SUM(distribution_misc_profits_amount) +
                SUM(distribution_structure_costs_amount) +
                SUM(distribution_withholding_tax_amount) +
                SUM(distribution_recallable_amount) +
                SUM(distribution_compensatory_interest_amount)
              ) - (
                SUM(capital_call_gross_amount) +
                SUM(capital_call_compensatory_interest_amount) +
                SUM(capital_call_management_fees_amount)
              ) AS net_cashflow_amount
            FROM investor_cashflows
            GROUP BY fund_cashflow_id
          ) agg_fc
          ON fc.id = agg_fc.fund_cashflow_id
        ) fund_cashflows
      "
    )
  }
  # rubocop:enable Metrics/BlockLength

  scope :with_open_state_count, lambda {
    from(
      "
        (
          SELECT fc.*, agg_fc.open_state_count
          FROM fund_cashflows fc
          LEFT JOIN (
            SELECT fund_cashflow_id AS fund_cashflow_id, COUNT(*) AS open_state_count
            FROM investor_cashflows
            WHERE aasm_state = 'open'
            GROUP BY fund_cashflow_id
          ) agg_fc
          ON fc.id = agg_fc.fund_cashflow_id
        ) fund_cashflows
      "
    )
  }

  def fund_cashflow_type
    net_cashflow_amount >= 0 ? :distribution : :capital_call
  end

  def net_cashflow_amount
    investor_cashflows.sum(&:net_cashflow_amount)
  end

  def state
    investor_cashflows.all?(&:finished?) ? :finished : :open
  end

  def archive_name
    cashflow_type = fund_cashflow_type == :distribution ? 'Ausschüttung' : 'Kapitalabruf'
    "Anschreiben_#{cashflow_type}_#{number}_#{fund.name}.zip"
  end

  private

  def assign_number
    self.number ||= (fund&.fund_cashflows&.pluck(:number)&.max || 0) + 1
  end
end

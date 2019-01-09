# frozen_string_literal: true

# == Schema Information
#
# Table name: fund_reports
#
#  id          :uuid             not null, primary key
#  valuta_date :date
#  irr         :decimal(20, 10)
#  description :text
#  fund_id     :uuid
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_fund_reports_on_fund_id  (fund_id)
#
# Foreign Keys
#
#  fk_rails_...  (fund_id => funds.id)
#

# Defines the FundReport
class FundReport < ApplicationRecord
  belongs_to :fund, inverse_of: :fund_reports, autosave: true
  has_and_belongs_to_many :investors, -> { distinct }

  has_paper_trail(
    meta: {
      parent_item_id: :fund_id,
      parent_item_type: 'Fund'
    },
    skip: SKIPPED_ATTRIBUTES
  )

  validates :valuta_date, presence: true
  validates :description, presence: true
  validates :fund, presence: true

  before_validation :assign_investors, on: :create

  private

  def assign_investors
    self.investors = fund.investors if fund.present?
  end
end

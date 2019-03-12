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
  has_many :investor_reports, dependent: :destroy
  has_many :investors, -> { distinct }, through: :investor_reports

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

  def archive_name
    date_string = valuta_date.strftime('%d.%m.%Y')
    "Quartalsberichte_#{fund.name}_#{date_string}.zip"
  end

  private

  def assign_investors
    self.investors = fund.investors if fund.present?
  end
end

# frozen_string_literal: true

# == Schema Information
#
# Table name: activities
#
#  created_at  :datetime         not null
#  creator_id  :uuid
#  description :text
#  ended_at    :datetime
#  ews_id      :string
#  id          :uuid             not null, primary key
#  started_at  :datetime
#  title       :string
#  type        :string
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_activities_on_creator_id  (creator_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#

# Defines the Activity model
class Activity < ApplicationRecord
  include Lockable
  strip_attributes only: :title, collapse_spaces: true

  attr_accessor :contacts_to_recalculate, :mandates_to_recalculate

  belongs_to :creator, class_name: 'User', inverse_of: :activities
  has_many :documents, as: :owner, inverse_of: :owner, dependent: :destroy
  has_and_belongs_to_many :mandates,
                          -> { distinct },
                          after_add: :mandate_mark_for_rescoring,
                          before_remove: :mandate_mark_for_resocring
  has_and_belongs_to_many :contacts,
                          -> { distinct },
                          after_add: :contact_mark_for_rescoring,
                          before_remove: :contact_mark_for_resocring

  has_paper_trail(skip: SKIPPED_ATTRIBUTES)

  validates :type, presence: true
  validates :title, presence: true
  validates :description, presence: true
  validates :started_at, presence: true
  validate :ended_at_greater_or_equal_started_at

  alias_attribute :activity_type, :type

  # before_commit :mark_objects_for_rescoring, on: :create
  # before_destroy :mark_objects_for_rescoring
  after_commit :rescore_objects, on: %i[create destroy]

  after_initialize do
    self.contacts_to_recalculate = []
    self.mandates_to_recalculate = []
  end

  def task_assignees
    [creator]
  end

  private

  def contact_mark_for_rescoring(contact)
    contacts_to_recalculate << contact.id if contact.activities.count == 1
  end

  def mandate_mark_for_rescoring(mandate)
    mandates_to_recalculate << mandate.id if mandate.activities.count == 1
  end

  # def mark_objects_for_rescoring
  #   contacts.each do |contact|
  #     contacts_to_recalculate << contact.id if contact.activities.count == 1
  #   end
  #   mandates.each do |mandate|
  #     mandates_to_recalculate << mandate.id if mandate.activities.count == 1
  #   end
  # end

  def rescore_objects
    contacts_to_recalculate.each do |id|
      contact = Contact.find(id)
      contact.calculate_score
      contact.save!
    end
    mandates_to_recalculate.each do |id|
      mandate = Contact.find(id)
      mandate.calculate_score
      mandate.save!
    end
  end

  # Validates if started_at timestamp is before ended_at if ended_at is set
  # @return [void]
  def ended_at_greater_or_equal_started_at
    return if ended_at.blank? || started_at.blank? || ended_at >= started_at

    errors.add(:ended_at, 'has to be after or at started_at')
  end
end

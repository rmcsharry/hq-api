# frozen_string_literal: true

# Score activities when they get added
module ScoreableActivity
  extend ActiveSupport::Concern

  attr_accessor :contacts_to_recalculate, :mandates_to_recalculate

  # included do
  #   before_commit :mark_objects_for_rescoring, on: :create
  #   before_destroy :mark_objects_for_rescoring
  #   after_commit :rescore_objects, on: %i[create destroy]
  # end

  private

  def mark_objects_for_rescoring
    self.contacts_to_recalculate = []
    self.mandates_to_recalculate = []
    contacts.each do |contact|
      contacts_to_recalculate << contact.id if one_activity?(contact)
    end
    mandates.each do |mandate|
      mandates_to_recalculate << mandate.id if one_activity?(mandate)
    end
  end

  def one_activity?(object:)
    object.activities.count == 1
  end

  def rescore_objects
    rescore_contacts if contacts_to_recalculate.count.positive?
    rescore_mandates if mandates_to_recalculate.count.positive?
  end

  def rescore_contacts
    Contact.skip_callback(:save, :before, :calculate_score, raise: false)
    contacts_to_recalculate.each do |id|
      contact = Contact.find(id)
      contact.calculate_score
      contact.save!
    end
    Contact.set_callback(:save, :before, :calculate_score, if: :has_changes_to_save?)
  end

  def rescore_mandates
    Mandate.skip_callback(:save, :before, :calculate_score, raise: false)
    mandates_to_recalculate.each do |id|
      mandate = Mandate.find(id)
      mandate.calculate_score
      mandate.save!
    end
    Mandate.set_callback(:save, :before, :calculate_score, if: :has_changes_to_save?)
  end
end

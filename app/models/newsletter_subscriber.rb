# frozen_string_literal: true

# == Schema Information
#
# Table name: newsletter_subscribers
#
#  id                       :uuid             not null, primary key
#  email                    :string           not null
#  first_name               :string
#  last_name                :string
#  gender                   :string
#  professional_title       :string
#  nobility_title           :string
#  confirmation_token       :string
#  mailjet_list_id          :string
#  confirmation_base_url    :string
#  confirmation_success_url :string
#  aasm_state               :string
#  confirmed_at             :datetime
#  confirmation_sent_at     :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

# Defines the Newsletter Subscriber model
class NewsletterSubscriber < ApplicationRecord
  include AASM
  extend Enumerize

  has_paper_trail(
    meta: {
      parent_item_id: :id,
      parent_item_type: 'NewsletterSubscriber'
    },
    skip: SKIPPED_ATTRIBUTES
  )

  aasm do
    state :created, initial: true
    state :confirmation_sent
    state :confirmed

    event :send_confirmation do
      before :send_confirmation_instructions
      after :save

      transitions from: :created, to: :confirmation_sent
    end

    event :confirm do
      before :assign_confirmed_properties
      after :schedule_sync

      transitions from: :confirmation_sent, to: :confirmed
    end
  end

  alias_attribute :state, :aasm_state

  validates :first_name, presence: true, if: :last_name
  validates :last_name, presence: true, if: :first_name
  validates :mailjet_list_id, presence: true
  validates :confirmation_base_url, presence: true
  validates :confirmation_success_url, presence: true
  validates :email, presence: true, email: true

  validate :attributes_in_confirmed_state

  enumerize :gender, in: Contact::Person::GENDERS, scope: true
  enumerize :nobility_title, in: Contact::Person::NOBILITY_TITLES, scope: true
  enumerize :professional_title, in: Contact::Person::PROFESSIONAL_TITLES, scope: true

  before_validation :normalize_email
  after_create :send_confirmation

  def self.confirm_by_token!(confirmation_token)
    subscriber = find_subscriber_by_confirmation_token(confirmation_token)
    subscriber.confirm if subscriber&.persisted?
    subscriber
  end

  def self.find_subscriber_by_confirmation_token(original_token)
    confirmation_token = Devise.token_generator.digest(self, :confirmation_token, original_token)
    find_by(confirmation_token: confirmation_token)
  end

  private

  # Validates presence of confirmed_at if state is `confirmed`
  # @return [void]
  def attributes_in_confirmed_state
    return unless confirmed?

    error_message = 'must be present if newsletter subscriber is confirmed'
    errors.add(:confirmed_at, error_message) if confirmed_at.nil?
  end

  def assign_confirmed_properties
    self.confirmation_token = nil
    self.confirmed_at = Time.zone.now if confirmed_at.nil?
  end

  def generate_confirmation_token
    raw, enc = Devise.token_generator.generate(self.class, :confirmation_token)
    @raw_confirmation_token = raw
    self.confirmation_token = enc
    self.confirmation_sent_at = Time.zone.now
  end

  # Send confirmation instructions by email
  def send_confirmation_instructions
    generate_confirmation_token unless @raw_confirmation_token

    NewsletterSubscriberMailer.with(
      record: self, confirmation_token: @raw_confirmation_token
    ).confirmation_instructions.deliver_later
  end

  def schedule_sync
    save!
    SyncNewsletterSubscriberJob.perform_later(id)
  end

  def normalize_email
    self.email = email.strip.downcase if email.present?
  end
end

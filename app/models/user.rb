# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_type        :string
#  invited_by_id          :bigint(8)
#  invitations_count      :integer          default(0)
#  comment                :text
#  contact_id             :uuid
#  ews_user_id            :string
#
# Indexes
#
#  index_users_on_confirmation_token                 (confirmation_token) UNIQUE
#  index_users_on_contact_id                         (contact_id)
#  index_users_on_email                              (email) UNIQUE
#  index_users_on_invitation_token                   (invitation_token) UNIQUE
#  index_users_on_invitations_count                  (invitations_count)
#  index_users_on_invited_by_id                      (invited_by_id)
#  index_users_on_invited_by_type_and_invited_by_id  (invited_by_type,invited_by_id)
#  index_users_on_reset_password_token               (reset_password_token) UNIQUE
#  index_users_on_unlock_token                       (unlock_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (contact_id => contacts.id)
#

# Defines the User model used for authentication
class User < ApplicationRecord
  attr_accessor :authenticated_via_ews

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :async, :invitable, :registerable, :recoverable, :rememberable, :trackable,
         :validatable, :jwt_authenticatable, :confirmable, :lockable,
         jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  belongs_to :contact
  has_many :activities, inverse_of: :creator, foreign_key: :creator_id, dependent: :nullify
  has_many :documents, inverse_of: :uploader, foreign_key: :uploader_id, dependent: :nullify
  has_many :created_versions, class_name: 'Version', inverse_of: :whodunnit, dependent: :nullify
  has_and_belongs_to_many :user_groups, uniq: true

  has_paper_trail(
    ignore: %i[sign_in_count current_sign_in_at last_sign_in_at current_sign_in_ip last_sign_in_ip],
    skip: SKIPPED_ATTRIBUTES
  )

  before_save :downcase_email

  PASSWORD_REGEX = /\A(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[^\p{Alpha}\d]).{10,128}\z/
  validates :password, format: { with: PASSWORD_REGEX, message: :password_complexity }, if: :password_present?

  scope :with_user_group_count, lambda {
    from(
      '(SELECT u.*, ugc.user_group_count FROM users u LEFT JOIN (SELECT ugu.user_id AS ' \
      'user_id, COUNT(*) AS user_group_count FROM user_groups_users ugu GROUP BY ugu.user_id) ' \
      'ugc ON u.id = ugc.user_id) users'
    )
  }

  def jwt_payload
    payload = { roles: user_groups.map(&:roles).flatten.uniq }
    payload[:scope] = :ews if authenticated_via_ews
    payload
  end

  def self.send_reset_password_instructions(email:, reset_password_url:)
    user = User.find_by(email: email)
    user.send_reset_password_instructions(reset_password_url: reset_password_url) if user&.persisted?
    user
  end

  def send_reset_password_instructions(reset_password_url:)
    token = set_reset_password_token
    send_reset_password_instructions_notification(token: token, reset_password_url: reset_password_url)
    token
  end

  def setup_ews_id(id_token)
    return if id_token.blank? || ews_user_id.present?
    decoded_token = DecodeEWSIdTokenService.call id_token
    appctx = JSON.parse(decoded_token['appctx'])
    update ews_user_id: appctx['msexchuid']
  rescue JWT::DecodeError => _
    nil
  end

  protected

  def send_reset_password_instructions_notification(token:, reset_password_url:)
    send_devise_notification(:reset_password_instructions, token, reset_password_url: reset_password_url)
  end

  private

  def downcase_email
    self.email = email.downcase
  end

  def password_present?
    password.present?
  end
end

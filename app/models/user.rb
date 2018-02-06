# Defines the User model used for authentication
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :invitable, :registerable, :recoverable, :rememberable, :trackable, :validatable,
         :jwt_authenticatable, :confirmable, :lockable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null
end

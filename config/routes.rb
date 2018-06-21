# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  # Skip all controllers but bind devise for mailers
  devise_for :users,
             defaults: { format: :json },
             path: 'v1/users',
             skip: %i[sessions passwords registrations confirmations unlocks invitations]

  namespace :v1 do
    jsonapi_resources :activities
    jsonapi_resources :addresses
    jsonapi_resources :bank_accounts
    jsonapi_resources :contact_details
    jsonapi_resources :contacts
    jsonapi_resources :documents
    jsonapi_resources :foreign_tax_numbers
    jsonapi_resources :mandate_groups
    jsonapi_resources :mandate_members
    jsonapi_resources :mandates
    jsonapi_resources :organization_members
    jsonapi_resources :tax_details
    jsonapi_resources :user_groups
    jsonapi_resources :users

    post 'users/sign-in',                             to: 'users#sign_in_user'
    get  'users/validate-token',                      to: 'users#validate_token'
    get  'users/invitation/:invitation_token',        to: 'users#read_invitation'
    post 'users/invitation/:invitation_token',        to: 'users#accept_invitation'
    post 'users/set-password/:reset_password_token',  to: 'users#reset_password'
  end

  root to: 'v1/users#index'

  get 'health', to: proc { [200, {}, ['']] }
end
# rubocop:enable Metrics/BlockLength

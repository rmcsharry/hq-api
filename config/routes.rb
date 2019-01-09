# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  # Skip all controllers but bind devise for mailers
  devise_for :users,
             defaults: { format: :json },
             path: 'v1/users',
             skip: %i[sessions passwords registrations unlocks invitations]

  namespace :v1 do
    jsonapi_resources :activities
    jsonapi_resources :addresses
    jsonapi_resources :bank_accounts
    jsonapi_resources :compliance_details
    jsonapi_resources :contact_details
    jsonapi_resources :contacts
    jsonapi_resources :documents
    jsonapi_resources :foreign_tax_numbers
    jsonapi_resources :fund_cashflows
    jsonapi_resources :fund_reports
    jsonapi_resources :funds
    jsonapi_resources :inter_person_relationships
    jsonapi_resources :investor_cashflows
    jsonapi_resources :investors
    jsonapi_resources :mandate_groups
    jsonapi_resources :mandate_members
    jsonapi_resources :mandates
    jsonapi_resources :organization_members
    jsonapi_resources :tax_details
    jsonapi_resources :user_groups
    jsonapi_resources :users

    post  'users/sign-in',                                    to: 'users#sign_in_user'
    post  'users/sign-in-ews-id',                             to: 'users#sign_in_ews_id'
    get   'users/validate-token',                             to: 'users#validate_token'
    get   'users/invitation/:invitation_token',               to: 'users#read_invitation'
    post  'users/invitation/:invitation_token',               to: 'users#accept_invitation'
    post  'users/set-password/:reset_password_token',         to: 'users#reset_password'
    patch 'users/:id/deactivate',                             to: 'users#deactivate'
    patch 'users/:id/reactivate',                             to: 'users#reactivate'
    post  'investor-cashflows/:id/finish',                    to: 'investor_cashflows#finish'
    get   'investor-cashflows/:id/filled-fund-template',      to: 'investor_cashflows#filled_fund_template'
    get   'investors/:id/filled-fund-subscription-agreement', to: 'investors#filled_fund_subscription_agreement'
    get   'investors/:id/filled-fund-quarterly-report',       to: 'investors#filled_fund_quarterly_report'
  end

  root to: 'v1/users#index'

  get 'health', to: 'healthcheck#health'
end
# rubocop:enable Metrics/BlockLength

# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength, Metrics/LineLength
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
    jsonapi_resources :contact_relationships
    jsonapi_resources :contacts
    jsonapi_resources :documents
    jsonapi_resources :foreign_tax_numbers
    jsonapi_resources :fund_cashflows
    jsonapi_resources :fund_reports
    jsonapi_resources :funds
    jsonapi_resources :investor_cashflows
    jsonapi_resources :investors
    jsonapi_resources :list_items
    jsonapi_resources :lists
    jsonapi_resources :mandate_groups
    jsonapi_resources :mandate_members
    jsonapi_resources :mandates
    jsonapi_resources :newsletter_subscribers
    jsonapi_resources :state_transitions
    jsonapi_resources :task_comments
    jsonapi_resources :tasks
    jsonapi_resources :tax_details
    jsonapi_resources :user_groups
    jsonapi_resources :users

    get   'newsletter-subscribers/confirm-subscription',                    to: 'newsletter_subscribers#confirm_subscription'
    post  'users/sign-in',                                                  to: 'users#sign_in_user'
    post  'users/sign-in-ews-id',                                           to: 'users#sign_in_ews_id'
    get   'users/validate-token',                                           to: 'users#validate_token'
    get   'users/invitation/:invitation_token',                             to: 'users#read_invitation'
    post  'users/invitation/:invitation_token',                             to: 'users#accept_invitation'
    post  'users/set-password/:reset_password_token',                       to: 'users#reset_password'
    patch 'users/:id/deactivate',                                           to: 'users#deactivate'
    patch 'users/:id/reactivate',                                           to: 'users#reactivate'
    get   'investors/:id/fund-subscription-agreement-document',             to: 'investors#fund_subscription_agreement_document'
    get   'investors/:id/regenerated-fund-subscription-agreement-document', to: 'investors#regenerated_fund_subscription_agreement_document'
    post  'investor-cashflows/:id/finish',                                  to: 'investor_cashflows#finish'
    get   'investor-cashflows/:id/cashflow-document',                       to: 'investor_cashflows#cashflow_document'
    get   'investor-reports/:id/quarterly-report-document',                 to: 'investor_reports#quarterly_report_document'
    get   'fund-cashflows/:id/archived-documents',                          to: 'fund_cashflows#archived_documents'
    get   'fund-reports/:id/archived-documents',                            to: 'fund_reports#archived_documents'
  end

  root to: 'v1/users#index'

  get 'health', to: 'healthcheck#health'
end
# rubocop:enable Metrics/BlockLength, Metrics/LineLength

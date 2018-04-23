# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users,
             defaults: { format: :json },
             path: 'v1/users'

  namespace :v1 do
    jsonapi_resources :addresses
    jsonapi_resources :contact_details
    jsonapi_resources :contacts
    jsonapi_resources :documents
    jsonapi_resources :foreign_tax_numbers
    jsonapi_resources :mandate_members
    jsonapi_resources :mandates
    jsonapi_resources :organization_members
  end

  root to: 'v1/users#index'

  get 'health', to: proc { [200, {}, ['']] }
end

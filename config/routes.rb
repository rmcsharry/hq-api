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
  end

  root to: 'v1/users#index'

  get 'health', to: proc { [200, {}, ['']] }
end

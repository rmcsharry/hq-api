Rails.application.routes.draw do
  devise_for :users,
             defaults: { format: :json },
             path: 'v1/users'

  namespace :v1 do
    jsonapi_resources :contacts
    jsonapi_resources :addresses
  end

  get 'health', to: proc { [200, {}, ['']] }
end

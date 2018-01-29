Rails.application.routes.draw do
  namespace :v1 do
    jsonapi_resources :contacts
    jsonapi_resources :addresses
  end

  get 'health', to: proc { [200, {}, ['']] }
end

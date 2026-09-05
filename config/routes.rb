Rails.application.routes.draw do
  # get "group_settings/show"
  # get "group_chats/show"
  # get "group_membership_requests/index"
  # get "group_members/index"
  # get "group_events/index"
  # get "groups/index"
  # get "groups/new"
  # get "registrations/new"
  # get "dashboard/index"
  # get "home/index"
  resource :session
  resources :passwords, param: :token
  resource :registration, only: [:new, :create]

  resources :groups, only: [:index, :new, :create, :show] do
    resource :membership, only: [:create, :destroy]

    get "events",               to: "group_events#index"
    get "members",              to: "group_members#index"
    get "chat",                 to: "group_chats#show"
    get "settings",             to: "group_settings#show"

    get "membership_requests",
          to: "group_membership_requests#index"

    patch "membership_requests/:id/approve",
          to: "group_membership_requests#approve",
          as: :approve_membership_request

    patch "membership_requests/:id/reject",
          to: "group_membership_requests#reject",
          as: :reject_membership_request
  end
  get "my_groups", to: "groups#my_groups"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"

  get "dashboard", to: "dashboard#index"
end

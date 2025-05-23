Rails.application.routes.draw do
  # Ruta pública para acceder a rounds por hash_id
  get "rounds/public", to: "round#public_show"

  resources :rounds, controller: "round" do
    resources :participants, only: [ :create, :destroy, :update ]
    resources :subgroups, only: [ :create, :destroy ] do
      resources :samplings, only: [ :create ]
    end
    resources :samplings, only: [ :create ], as: "global_samplings"
    resource :counters, only: [] do
      post :reset, on: :collection
    end
  end
  devise_for :users

  devise_scope :user do
    get "/users/sign_out" => "devise/sessions#destroy"
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  root "round#index"
end

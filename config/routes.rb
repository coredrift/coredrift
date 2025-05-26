Rails.application.routes.draw do
  get "dailies/new"
  get "dailies/create"
  get "dailies/showbin/rails"
  get "dailies/generate"
  get "dailies/controller"
  get "dailies/Dailies"
  get "dailies/new"
  get "dailies/create"
  get "dailies/show"
  resource :session, only: [ :new, :create, :destroy ]
  delete "session", to: "sessions#destroy", as: :logout
  get    "session", to: "sessions#show"

  # Users routes
  resources :users do
    member do
      get    :roles
      post   :assign_role
      delete "roles/:role_id",       action: :revoke_role,       as: :revoke_role

      get    :permissions
      post   :assign_permission
      delete "permissions/:permission_id",
             action: :revoke_permission, as: :revoke_permission
    end
    resources :roles,       only: [ :index, :update ]
    resources :permissions, only: [ :index, :update ]
  end

  get "users/new"
  get "users/create"

  resources :passwords, param: :token

  # menu links
  resources :roles do
    member do
      get    :permissions
      post   :assign_permission
      delete "permissions/:permission_id", action: :revoke_permission, as: :revoke_permission
    end
  end
  resources :permissions
  resources :resources do
    member do
      get    :permissions
      post   :assign_permission
      delete "permissions/:permission_id", action: :revoke_permission, as: :revoke_permission
    end
  end

  resources :organizations, only: [ :show, :edit, :update ]
  resources :teams, only: [ :index, :show, :new, :edit, :update ] do
    member do
      get :members
      delete "members/:user_id", to: "teams#remove_member", as: :remove_member
      post   "members/:user_id", to: "teams#add_member",    as: :add_member
    end
    resources :daily_setups, only: [ :new, :create, :edit, :update ], shallow: true

    # Dailies nested under teams for index/new/create, shallow routes
    resources :dailies, only: [ :index, :new, :create ], shallow: true
  end

  # Shallow routes for Dailies show/edit/update/destroy
  resources :dailies, only: [ :show, :edit, :update, :destroy ]
  resources :dailies, only: [ :new, :create, :show ]

  get "todo", to: "todo#index", as: :todo_index

  get "test/fake_action", to: "test#fake_action"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
  # root "posts#index"

  get "/dash",               to: "dash#dash"
  get "/dash/add_member",    to: "dash#add_member",    as: "add_member_dash"
  get "/dash/remove_member", to: "dash#remove_member", as: "remove_member_dash"
end

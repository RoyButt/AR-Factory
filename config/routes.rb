Rails.application.routes.draw do
  get    "login",  to: "sessions#new",     as: :login
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  get "dashboard", to: "dashboard#index", as: :dashboard

  get "records", to: "records#index", as: :records
  get "records/export", to: "records#export", as: :records_export

  get "master_data", to: "master_data#index", as: :master_data
  resources :designs, except: %i[index show]
  resources :fabric_types, only: %i[create update destroy]
  resources :workers, only: %i[create update destroy]
  patch "settings", to: "settings#update", as: :settings

  resources :cost_cards do
    member { post :rotate_image }
  end
  resources :fabric_lots do
    member do
      post   :apply_pattern
      post   :finalize_pattern
      delete :remove_pattern
      get    :gate_pass
    end
  end
  resources :emb_parties
  get "emb_master", to: "emb_master#index", as: :emb_master
  resources :cutwork_parties
  resources :handmade_parties
  resources :khatta_embs, only: %i[index] do
    collection do
      post   :add_return
      post   :complete_delivery
      post   :set_rate
      post   :set_claim
      patch  :update_return
      delete :remove_return
      delete :delete_returns
    end
  end
  get    "khatta_billing", to: "khatta_billing#index", as: :khatta_billing
  post   "khatta_billing/add_payment",    to: "khatta_billing#add_payment",    as: :add_khatta_payment
  post   "khatta_billing/set_amount",     to: "khatta_billing#set_amount",     as: :set_khatta_amount
  delete "khatta_billing/remove_payment", to: "khatta_billing#remove_payment", as: :remove_khatta_payment

  resources :stock_entries, only: %i[index create update destroy] do
    collection do
      post :send_for_stitching
      post :cancel_stitching
    end
  end

  resources :production_parties
  get  "stitching", to: "stitching#index", as: :stitching
  post "stitching/prepare_sheet", to: "stitching#prepare_sheet", as: :stitching_prepare_sheet
  resources :production_sheets, only: %i[index new create edit update destroy] do
    member do
      post :claim
      post :complete
      post :reopen
    end
  end
  get  "cutwork_progress",  to: "production_progress#index", as: :cutwork_progress,  defaults: { stage: "cutwork" }
  get  "handmade_progress", to: "production_progress#index", as: :handmade_progress, defaults: { stage: "handmade" }
  post "production_progress/:id/assign", to: "production_progress#assign", as: :assign_progress
  post "production_progress/:id/set_adjustment", to: "production_progress#set_adjustment", as: :set_adjustment_progress
  post "production_progress/:id/generate_pass", to: "production_progress#generate_pass", as: :generate_pass
  get  "handmade_pass/:id", to: "production_progress#pass", as: :handmade_pass
  post "handmade_pass/:id/adjustment", to: "production_progress#set_pass_adjustment", as: :set_pass_adjustment
  post "production_progress/:id/claim_suit", to: "production_progress#claim_suit", as: :claim_suit
  resources :stitching_cost_cards, only: %i[index create destroy]
  get    "production_khata", to: "production_khata#index", as: :production_khata
  post   "production_khata/add_payment",    to: "production_khata#add_payment",    as: :add_production_payment
  delete "production_khata/remove_payment", to: "production_khata#remove_payment", as: :remove_production_payment
  get    "production_payroll", to: "production_payroll#index", as: :production_payroll
  get    "cutwork_billing", to: "cutwork_billing#index", as: :cutwork_billing
  post   "cutwork_billing/add_payment",    to: "cutwork_billing#add_payment",    as: :add_cutwork_payment
  delete "cutwork_billing/remove_payment", to: "cutwork_billing#remove_payment", as: :remove_cutwork_payment

  get    "handwork_billing", to: "handwork_billing#index", as: :handwork_billing
  post   "handwork_billing/add_payment",    to: "handwork_billing#add_payment",    as: :add_handwork_payment
  delete "handwork_billing/remove_payment", to: "handwork_billing#remove_payment", as: :remove_handwork_payment

  get "analytics", to: "analytics#index", as: :analytics
  get "analytics/export", to: "analytics#export", as: :analytics_export

  resources :team, controller: "team", only: %i[index new create edit update destroy]

  resources :production_lots, only: %i[new create edit update destroy]

  root to: "sessions#new"
end

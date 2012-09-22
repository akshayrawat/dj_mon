DjMon::Engine.routes.draw do

  resources :dj_reports do
    collection do
      get :all
      get :failed
      get :active
      get :queued
      get :dj_counts
      get :settings
    end
    member do
      post :retry
    end
  end

  root :to => 'dj_reports#index'
end

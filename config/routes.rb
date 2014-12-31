require 'sidekiq/web'

Rails.application.routes.draw do
  root 'static_pages#home'
  
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
  
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  devise_for :users, path: '', controllers: { registrations: 'users/registrations', sessions: 'users/sessions' }

  get 'meet' => 'static_pages#meet', as: 'meet'
  get 'faq' => 'static_pages#faq', as: 'faq'

  resources :availabilities # TODO remove? currently implemented via rails_admin
  resources :appointments, only: [:index, :show, :update]
  resources :student_materials, only: [:update]
  get 'dashboard' => 'users#student_dashboard', as: 'student_dashboard'
  post 'charges' => 'charges#create'
end

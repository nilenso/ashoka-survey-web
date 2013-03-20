SurveyWeb::Application.routes.draw do

  scope "(:locale)", :locale => /#{I18n.available_locales.join('|')}/ do
    match '/auth/:provider/callback', :to => 'sessions#create'
    match '/auth/failure', :to => 'sessions#failure'
    match '/logout', :to => 'sessions#destroy', :as => 'logout'

    resources :surveys, :only => [:new, :create, :destroy, :index] do
      resource :publication, :only => [:update, :edit, :destroy] do
        get 'unpublish'
      end
      member do
       post "duplicate"
       get  "report"
      end
      get 'build'
      put 'finalize'
      put 'archive'
      match  "public_response" => "responses#create"
      resources :responses, :only => [:new, :create, :index, :edit, :show, :update, :destroy] do
        collection { get "generate_excel" }
        member do
          put "complete"
        end
      end
    end

    resources :records, :only => [:create, :destroy]

    root :to => 'surveys#index'
  end

  namespace :api, :defaults => { :format => 'json' } do
    scope :module => :v1 do
      get '/jobs/:id/alive' => "jobs#alive"
      resources :questions, :except => [:edit, :new] do
        member { post "duplicate" }
      end
      resources :records, :only => [:create, :update] do
        collection { get 'ids_for_response' }
      end
      resources :categories, :except => [:edit, :new] do
        member { post "duplicate" }
      end
      resources :audits, :only => [:create, :update]
      resources :options, :except => [:edit, :new, :show]
      resources :surveys, :only => [:index, :show, :update] do
        get 'questions_count', :on => :collection
        get 'identifier_questions', :on => :member
      end
      match '/login', :to => 'auth#create'
      resources :responses, :only => [:create, :update, :index, :show] do
        member { put "image_upload" }
        collection { get 'count' }
      end
      post 'questions/:id/image_upload' => 'questions#image_upload'
    end
  end
end

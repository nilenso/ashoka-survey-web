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
        member { put "complete" }
      end
    end

    resources :records, :only => [:create, :destroy]

    root :to => 'surveys#index'
  end

  namespace :api, :defaults => { :format => 'json' } do
    scope :module => :v1 do
      resources :questions, :except => [:edit, :new] do
        member { post "duplicate" }
      end
      resources :records, :only => :create
      resources :categories, :except => [:edit, :new] do
        member { post "duplicate" }
      end
      resources :audits, :only => [:create, :update]
      resources :options, :except => [:edit, :new, :show]
      resources :surveys, :only => [:index, :show, :update] do
        get 'questions_count', :on => :collection
      end
      match '/login', :to => 'auth#create'
      resources :responses, :only => [:create, :update, :index, :show] do
        member { put "image_upload" }
      end
      post 'questions/:id/image_upload' => 'questions#image_upload'
    end
  end
end

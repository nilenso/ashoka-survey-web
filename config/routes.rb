SurveyWeb::Application.routes.draw do
  scope "(:locale)", :locale => /#{I18n.available_locales.join('|')}/ do
    match '/auth/:provider/callback', :to => 'sessions#create'
    match '/auth/failure', :to => 'sessions#failure'
    match '/logout', :to => 'sessions#destroy', :as => 'logout'

    match '/surveys/build/:id', :to => 'surveys#build', :as => "surveys_build"

    resources :surveys do
      get 'publish_to_users', 'share_with_organizations'
      put 'update_publish_to_users'
      resources :responses, :only => [:new, :create, :show, :index]
      get 'share' => 'survey_share#edit'
      put 'share' => 'survey_share#update'
    end
    root :to => 'surveys#index'
  end

  namespace :api, :defaults => { :format => 'json' } do
    scope :module => :v1 do
      resources :questions, :except => [:edit, :new]
      resources :options, :except => [:edit, :new, :show]
      resources :surveys, :only => [:index, :show]
      resources :responses, :only => [:create, :update]
      post 'questions/:id/image_upload' => 'questions#image_upload'
    end
  end
end

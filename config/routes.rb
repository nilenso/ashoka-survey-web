SurveyWeb::Application.routes.draw do
  scope "(:locale)", :locale => /#{I18n.available_locales.join('|')}/ do
    match '/auth/:provider/callback', :to => 'sessions#create'
    match '/signout', :to => 'sessions#destroy', :as => 'signout'

    match '/surveys/build/:id', :to => 'surveys#build', :as => "surveys_build"
    match '/surveys/backbone_create', :to => 'surveys#backbone_create'
    match '/surveys/backbone_new', :to => 'surveys#backbone_new'

    resources :surveys do
      resources :responses, :only => [:new, :create, :show]
    end
    root :to => 'surveys#index' 
  end

  namespace :api, :defaults => { :format => 'json' } do
    scope :module => :v1 do
      resources :questions, :only => [:create, :update]
      resources :options, :only => [:create]
    end
  end
end

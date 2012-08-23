SurveyWeb::Application.routes.draw do
  scope "(:locale)", :locale => /#{I18n.available_locales.join('|')}/ do

    match '/auth/:provider/callback', :to => 'sessions#create'
    match '/signout', :to => 'sessions#destroy', :as => 'signout'

    resources :surveys do
      resources :responses, :only => [:new, :create, :show]
    end

    root :to => 'surveys#index'
  end
end

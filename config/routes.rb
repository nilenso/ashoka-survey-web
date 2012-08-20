SurveyWeb::Application.routes.draw do
  scope "(:locale)", :locale => /#{I18n.available_locales.join('|')}/ do
    resources :surveys do
      resources :responses, :only => [:new, :create, :show]
    end
  end
  
  root :to => 'surveys#index'
  match "/(:locale)" => 'surveys#index', :as => :root_in_current_locale, :locale => /#{I18n.available_locales.join('|')}/
end

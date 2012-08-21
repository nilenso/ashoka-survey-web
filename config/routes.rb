SurveyWeb::Application.routes.draw do
  scope "(:locale)", :locale => /#{I18n.available_locales.join('|')}/ do
    resources :surveys do
      resources :responses, :only => [:new, :create, :show]
    end
    root :to => 'surveys#index'
  end
end

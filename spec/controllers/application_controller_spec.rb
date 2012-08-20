require 'spec_helper'

describe ApplicationController do
  # mocking index action for testing locale
  controller do
    def index
      redirect_to root_path
    end
  end

  context "when setting the locale based on params" do
    after(:each) { I18n.locale = I18n.default_locale }

    it "should set locale to french if params[:locale] is fr" do
      get :index, :locale => 'fr'
      I18n.locale.should == :fr
    end
  end

  context "when generating paths without passing the locale" do
    it "sets the locale param to fr when the locale is fr" do
      I18n.locale = 'fr'
      new_survey_path.should match /fr.*/
    end

    it "doesn't set the locale param when the locale is en" do
      I18n.locale = 'en'
      new_survey_path.should_not match /en.*/
    end
  end
end
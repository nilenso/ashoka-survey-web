require 'spec_helper'

describe ApplicationController do
  controller do
    # mocking index action for testing locale
    def index
      redirect_to root_path
    end

    # mocking create action for testing expired token
    def create
      response = RSpec::Mocks::Mock.new(:error= => :error, :parsed => nil, :body => nil, :status => 401)
      raise OAuth2::Error.new(response)
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

  context "when the OAuth2 session token expires" do
    it "clears the session hash" do
      session[:user_id] = 'sigurros'
      session[:access_token] = 'isawesome'

      post :create

      session[:user_id].should be_nil
      session[:access_token].should be_nil
      flash[:alert].should_not be_empty
      response.should redirect_to root_path
    end
  end

  it "knows if a user is currently signed in or not" do
    controller.user_currently_logged_in?.should be_false
    session[:user_id] = 1
    controller.user_currently_logged_in?.should be_true
  end

  it "knows if the current user is a cso admin" do
    sign_in_as('cso_admin')
    controller.signed_in_as_cso_admin?.should be_true
    sign_in_as('user')
    controller.signed_in_as_cso_admin?.should be_false
  end
end

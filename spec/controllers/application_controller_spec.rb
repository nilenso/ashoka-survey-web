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

  context "#current_ability" do
    controller(ApplicationController) do
      def index
        params[:controller] = 'responses' # RSpec sets this to `anonymous`. Couldn't get around it.
        render :text => "Foo!"
      end
    end

    context "if the user isn't logged in" do
      it "creates a `PublicAbility`" do
        get :index
        controller.current_ability.class.should == PublicAbility
      end
    end

    context "if the user is logged in" do
      it "creates the relevant `Ability`" do
        sign_in_as('viewer')
        controller.current_ability.class.should == ViewerAbility
      end
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

  it "returns current user id" do
    controller.current_user.should be_nil
    session[:user_id] = 1
    controller.current_user.should == 1
  end

  it "returns current user organization id" do
    controller.current_user_org.should be_nil
    session[:user_id] = 12
    session[:user_info] = {:org_id => 23}
    controller.current_user_org.should == 23
  end

  it "returns current user organization type" do
    controller.current_user_org_type.should be_nil
    session[:user_id] = 12
    session[:user_info] = {:org_type => "CSO"}
    controller.current_user_org_type.should == "CSO"
  end

  context "#current_user_info" do
    it "returns current user info along with the user_id and the session_token" do
      session[:user_id] = 12
      session[:user_info] = {:org_id => 23}
      session[:session_token] = "foo"
      controller.current_user_info.should == { :org_id => 23, :user_id => 12, :session_token => "foo" }
    end

    it "returns the session_token if no user is logged in" do
      session[:session_token] = "foo"
      controller.current_user_info.should == { :session_token => "foo" }
    end
  end

  it "knows if the current user is a cso admin" do
    sign_in_as('cso_admin')
    controller.signed_in_as_cso_admin?.should be_true
    sign_in_as('field_agent')
    controller.signed_in_as_cso_admin?.should be_false
  end

  it "returns current user's name" do
    sign_in_as('cso_admin')
    session[:user_info][:name] = 'Tim'
    controller.current_username.should == 'Tim'
  end

  context "session token" do
    it "retrieves the current session token" do
      session[:session_token] = "foo"
      controller.session_token.should == "foo"
    end

    it "generates a new session token if one does not exist" do
      session[:session_token] = nil
      controller.session_token.should be_present
    end
  end

  context "cancan - access denied" do
    controller(ApplicationController) do
      def create
        raise CanCan::AccessDenied.new("Not authorized!", :create, Survey)
      end
    end
    it "redirectd to root and shows a flash error " do
      sign_in_as('field_agent')
      post :create
      response.should redirect_to('/')
      flash[:error].should_not be_nil
    end
  end

  context "paths for user_owner tasks" do
    it "returns the path to register an organization" do
      controller.register_path.should match /#{ENV['OAUTH_SERVER_URL']}\/register/
    end

    it "returns the path to create a user" do
      sign_in_as('cso_admin')
      controller.new_user_path.should match /#{ENV['OAUTH_SERVER_URL']}/
      controller.new_user_path.should match /#{controller.current_user_org}/
      controller.new_user_path.should match /new/
    end
  end
end

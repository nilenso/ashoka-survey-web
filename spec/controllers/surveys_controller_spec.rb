require 'spec_helper'

describe SurveysController do
  render_views

  context "GET 'new'" do
    it "assigns the survey instance variable" do
      get :new
      assigns(:survey).should_not be_nil
    end

    it "responds with a new page" do
      get :new
      response.should be_ok
      response.should render_template('new')
    end
  end

  context "POST 'create'" do
    context "when save is successful" do
      it "assigns the survey instance variable" do
        post :create
        assigns(:survey).should_not be_nil
      end

      it "redirects to the root page" do
        post :create
        response.should redirect_to(:root)
      end
    end
  end
end

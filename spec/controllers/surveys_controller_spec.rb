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
    let(:survey) { FactoryGirl.attributes_for(:survey) }

    context "when save is successful" do
      it "assigns the survey instance variable" do
        post :create, :survey => survey
        assigns(:survey).should_not be_nil
      end

      it "redirects to the root page" do
        post :create, :survey => survey
        response.should redirect_to(:root)
      end

      it "creates a survey" do
        expect { post :create, :survey => survey }.to change { Survey.count }.by(1)
      end
    end

    context "when save is unsuccessful" do
      it "renders the new page" do
        post :create
        response.should be_ok
        response.should render_template(:new)
      end
    end
  end
end

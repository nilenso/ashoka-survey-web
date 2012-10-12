require 'spec_helper'

describe ResponsesController do
  let(:survey) { FactoryGirl.create(:survey_with_questions, :published => true, :organization_id => 1) }
  before(:each) do
    sign_in_as('cso_admin')
    session[:user_info][:org_id] = 1
  end

  context "GET 'new'" do
    it "renders a page to create a new response" do
      get :new, :survey_id => survey.id
      response.should be_ok
      response.should render_template(:new)
    end

    it "assigns a new response" do
      get :new, :survey_id => survey.id
      assigns(:response).should_not be_nil
    end

    it "assigns the appropriate survey" do
      get :new, :survey_id => survey.id
      assigns(:survey).should == survey
    end

    it "assigns new answers to the response corresponding to the survey questions" do
      get :new, :survey_id => survey.id
      assigns(:response).answers.size.should == survey.questions.size
      assigns(:response).answers.each { |answer| answer.should be_an Answer }
    end

    it "does not allow adding a response to a survey that is not published" do
      survey = FactoryGirl.create(:survey, :organization_id => 1)
      get :new, :survey_id => survey.id
      response.should redirect_to(surveys_path)
      flash[:error].should_not be_nil
    end
  end

  context "POST 'create'" do
    let(:response) { FactoryGirl.attributes_for(:response_with_answers)}

    it "sets the response instance variable" do
      post :create, :response => response, :survey_id => survey.id
      assigns(:response).should_not be_nil
    end

    context "when save is successful" do
      it "saves the response" do
        expect do
          post :create, :response => response, :survey_id => survey.id
        end.to change { Response.count }.by(1)
      end

      it "saves the response to the right survey" do
        post :create, :response => response, :survey_id => survey.id
        assigns(:response).survey.should ==  survey
      end

      it "saves the id of the user taking the response" do
        session[:user_id] = 1234
        post :create, :response => response, :survey_id => survey.id
        Response.find_by_survey_id(survey.id).user_id.should == 1234
      end

      it "redirects to the root path with a flash message" do
        post :create, :response => response, :survey_id => survey.id
        response.should redirect_to root_path
        flash[:notice].should_not be_nil
      end
    end

    context "when save is unsuccessful" do
      it "renders the 'new' page" do
        question = FactoryGirl.create(:question, :mandatory => true)
        response['answers_attributes'] = {}
        response['answers_attributes']['0'] = {'content' => '', 'question_id' => question.id}
        post :create, :response => response, :survey_id => survey.id
        response.should render_template :new
      end
    end
  end

  context "GET 'index'" do
    it "renders the list of responses for a survey if a cso admin is signed in" do
      survey = FactoryGirl.create(:survey, :published => true, :organization_id => 1)
      res = FactoryGirl.create(:response, :survey => survey,
                               :organization_id => 1, :user_id => 1)
      get :index, :survey_id => survey.id
      response.should be_ok
      assigns(:responses).should == Response.find_all_by_survey_id(survey.id)
    end
  end

  context "GET 'edit'" do
    it "renders the edit page" do
      survey = FactoryGirl.create(:survey, :published => true, :organization_id => 1)
      res = FactoryGirl.create(:response, :survey => survey,
                               :organization_id => 1, :user_id => 2)
      get :edit, :id => res.id, :survey_id => survey.id 
      response.should be_ok
      response.should render_template('edit')
    end

    it "assigns a survey and response" do
      survey = FactoryGirl.create(:survey, :published => true, :organization_id => 1)
      res = FactoryGirl.create(:response, :survey => survey,
                               :organization_id => 1, :user_id => 2)
      get :edit, :id => res.id, :survey_id => survey.id 
       assigns(:response).should == Response.find(res.id)
       assigns(:survey).should == survey
    end
  end

  context "PUT 'update'" do
    it "updates the response" do
      survey = FactoryGirl.create(:survey, :published => true, :organization_id => 1)
      question = FactoryGirl.create(:question, :survey => survey)
      res = FactoryGirl.create(:response, :survey => survey,
                               :organization_id => 1, :user_id => 2)
      answer = FactoryGirl.create(:answer, :question => question)
      res.answers << answer

      put :update, :id => res.id, :survey_id => survey.id, :response => 
      { :answers_attributes => { "0" => { :content => "yeah123", :id => answer.id} } }

      Answer.find(answer.id).content.should == "yeah123"
      response.should redirect_to survey_responses_path
      flash[:notice].should_not be_nil
    end 

    it "renders edit page in case of any validations error" do
      survey = FactoryGirl.create(:survey, :published => true, :organization_id => 1)
      question = FactoryGirl.create(:question, :survey => survey, :mandatory => true)
      res = FactoryGirl.create(:response, :survey => survey,
                               :organization_id => 1, :user_id => 2)
      answer = FactoryGirl.create(:answer, :question => question)
      res.answers << answer

      put :update, :id => res.id, :survey_id => survey.id, :response => 
      { :answers_attributes => { "0" => { :content => "", :id => answer.id} } }

      response.should render_template('edit')
      answer.reload.content.should == "MyText"
      flash[:error].should_not be_empty
    end
  end

  context "PUT 'complete'" do
    let(:resp) { FactoryGirl.create(:response, :survey_id => survey.id, :organization_id => 1, :user_id => 1) }

    it "marks the survey complete" do
      put :complete, :id => resp.id, :survey_id => resp.survey_id
      resp.reload.should be_complete
    end

    it "redirects to the response index page on success" do
      put :complete, :id => resp.id, :survey_id => resp.survey_id
      response.should redirect_to(survey_responses_path(resp.survey_id))
    end
  end

end

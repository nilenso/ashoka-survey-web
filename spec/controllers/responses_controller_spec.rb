require 'spec_helper'

describe ResponsesController do
  let(:survey) { FactoryGirl.create(:survey_with_questions, :published => true, :organization_id => 1) }
  before(:each) do
    sign_in_as('cso_admin')
    session[:user_info][:org_id] = 1
  end

  context "POST 'create'" do
    let(:survey) { FactoryGirl.create(:survey, :published => true, :organization_id => 1)}
    let(:question) { FactoryGirl.create(:question)}

    it "saves the response" do
      expect {
        post :create, :survey_id => survey.id

      }.to change { Response.count }.by(1)
    end

    it "saves the response to the right survey" do
      post :create, :survey_id => survey.id
      assigns(:response).survey.should ==  survey
    end

    it "saves the id of the user taking the response" do
      session[:user_id] = 1234
      post :create, :survey_id => survey.id
      Response.find_by_survey_id(survey.id).user_id.should == 1234
    end

    it "redirects to the root path with a flash message" do
      post :create, :survey_id => survey.id
      response.should redirect_to edit_survey_response_path(:id => Response.find_by_survey_id(survey.id).id)
      flash[:notice].should_not be_nil
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
    it "doesn't run validations on answers that are empty" do
      survey = FactoryGirl.create(:survey, :published => true, :organization_id => 1)
      question_1 = FactoryGirl.create(:question, :survey => survey, :max_length => 15)
      question_2 = FactoryGirl.create(:question, :survey => survey, :mandatory => true)
      res = FactoryGirl.create(:response, :survey => survey,
                               :organization_id => 1, :user_id => 2)
      answer_1 = FactoryGirl.create(:answer, :question => question_1, :response => res)
      answer_2 = FactoryGirl.create(:answer, :question => question_2, :response => res)
      res.answers << answer_1
      res.answers << answer_2

      put :update, :id => res.id, :survey_id => survey.id, :response =>
        { :answers_attributes => { "0" => { :content => "", :id => answer_2.id},
                                   "1" => { :content => "hello", :id => answer_1.id} } }

        answer_1.reload.content.should == "hello"
      response.should redirect_to survey_responses_path
      flash[:notice].should_not be_nil
    end

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
                               :organization_id => 1, :user_id => 2, :status => 'validating')
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

    it "marks the response complete" do
      put :complete, :id => resp.id, :survey_id => resp.survey_id
      resp.reload.should be_complete
    end

    it "redirects to the response index page on success" do
      put :complete, :id => resp.id, :survey_id => resp.survey_id
      response.should redirect_to(survey_responses_path(resp.survey_id))
    end

    it "updates the response" do
      survey = FactoryGirl.create(:survey, :published => true, :organization_id => 1)
      question = FactoryGirl.create(:question, :survey => survey)
      res = FactoryGirl.create(:response, :survey => survey,
                               :organization_id => 1, :user_id => 2)
      answer = FactoryGirl.create(:answer, :question => question)
      res.answers << answer

      put :complete, :id => res.id, :survey_id => survey.id, :response =>
        { :answers_attributes => { "0" => { :content => "yeah123", :id => answer.id} } }

      Answer.find(answer.id).content.should == "yeah123"
      response.should redirect_to survey_responses_path
      flash[:notice].should_not be_nil
    end

    it "marks the response incomplete if save is unsuccessful" do
      survey = FactoryGirl.create(:survey, :published => true, :organization_id => 1)
      question = FactoryGirl.create(:question, :survey => survey, :mandatory => true)
      res = FactoryGirl.create(:response, :survey => survey,
                               :organization_id => 1, :user_id => 2)
      answer = FactoryGirl.create(:answer, :question => question)
      res.answers << answer

      put :complete, :id => res.id, :survey_id => survey.id, :response =>
        { :answers_attributes => { "0" => { :content => "", :id => answer.id} } }
      res.reload.should_not be_complete
    end
  end

  context "DELETE 'destroy'" do
    let!(:survey) { FactoryGirl.create(:survey, :organization_id => 1, :published => true) }
    let!(:res) { FactoryGirl.create(:response, :survey => survey, :organization_id => 1, :user_id => 2) }

    it "deletes a survey" do
      expect { delete :destroy, :id => res.id, :survey_id => survey.id }.to change { Response.count }.by(-1)
      flash[:notice].should_not be_nil
    end

    it "redirects to the survey index page" do
      delete :destroy, :id => res.id, :survey_id => survey.id
      response.should redirect_to survey_responses_path
    end
  end
end

require 'spec_helper'

module Api
  module V1
    describe QuestionsController do
      let(:organization_id) { 12 }
      let(:survey) { FactoryGirl.create(:survey, :organization_id => organization_id) }

      before(:each) do
        sign_in_as('cso_admin')
        session[:user_info][:org_id] = organization_id
        response = double('response')
        parsed_response = { "email" => "admin@admin.com",
                            "id" => 1,
                            "name" => "cso_admin",
                            "organization_id" => 12,
                            "role" => "cso_admin"
                            }

        access_token = double('access_token')
        OAuth2::AccessToken.stub(:new).and_return(access_token)
        access_token.stub(:get).and_return(response)
        response.stub(:parsed).and_return(parsed_response)
      end
      context "POST 'create'" do
        it "creates a new question" do
          question = FactoryGirl.attributes_for(:question, :type => 'RadioQuestion', :survey_id => survey.id)

          expect do
            post :create, :survey_id => survey.id, :question => question
          end.to change { Question.count }.by(1)
        end

        it "creates a new question based on the type" do
          question = FactoryGirl.attributes_for(:question, :survey_id => survey.id)
          question['type'] = 'RadioQuestion'
          expect do
            post :create, :survey_id => survey.id, :question => question
          end.to change { RadioQuestion.count }.by(1)
        end

        it "returns the created question as JSON" do
          expected_keys = Question.attribute_names
          question = FactoryGirl.attributes_for(:question, :type => 'RadioQuestion', :survey_id => survey.id)
          post :create, :survey_id => survey.id, :question => question

          response.should be_ok
          returned_json = JSON.parse(response.body)
          returned_json.keys.should =~ expected_keys
          returned_json['content'].should == question[:content]
        end

        context "when save is unsuccessful" do
          it "returns the errors with a bad_request status" do
            question = FactoryGirl.attributes_for(:question, :type => 'RadioQuestion', :survey_id => survey.id)
            question[:content] = ''
            post :create, :survey_id => survey.id, :question => question

            response.status.should == 400
            JSON.parse(response.body).should be_any {|m| m =~ /can\'t be blank/ }
          end
        end
      end

      context "PUT 'update'" do
        it "updates the question" do
          question = FactoryGirl.create(:question, :survey => survey)
          put :update, :id => question.id, :question => {:content => "hello"}
          Question.find(question.id).content.should == "hello"
        end

        it "returns the updated question as JSON, including it's type" do
          expected_keys = Question.attribute_names
          question = FactoryGirl.create(:question, :type => 'RadioQuestion', :survey => survey)
          put :update, :id => question.id, :question => {:content => "someuniquestring"}

          response.should be_ok
          returned_json = JSON.parse(response.body)
          returned_json.keys.should =~ expected_keys
          returned_json['content'].should == 'someuniquestring'
        end

        context "when update is unsuccessful" do
          it "returns the errors with a bad request status" do
            question = FactoryGirl.create(:question, :survey => survey)
            put :update, :id => question.id, :question => {:content => ""}
            response.status.should == 400
            JSON.parse(response.body).should be_any {|m| m =~ /can\'t be blank/ }
          end
        end
      end

      context "DELETE 'destroy'" do
        it "deletes the question" do
          question = FactoryGirl.create(:question, :survey => survey)
          delete :destroy, :id => question.id
          Question.find_by_id(question.id).should be_nil
        end

        it "handles an invalid ID passed in" do
          delete :destroy, :id => '1234567'
          response.should_not be_ok
        end

        it "deletes all the answers for that question" do
          question = FactoryGirl.create(:question, :survey => survey)
          answers = FactoryGirl.create_list(:answer, 5, :question_id => question.id)
          expect do
            delete :destroy, :id => question.id
          end.to change { Answer.count }.by(-5)
        end
      end

      context "POST image_upload" do
        it "uploads the image for given question" do
          question = FactoryGirl.create(:question, :survey => survey)
          @file = fixture_file_upload('/images/sample.jpg', 'text/xml')
          post :image_upload, :id => question.id, :image => @file
          response.should be_ok
          question.reload.image.should be
          question.reload.image.should_not eq '/images/original/missing.png'
        end

        it "returns the url for the image thumb as JSON" do
          question = FactoryGirl.create(:question, :survey => survey)
          @file = fixture_file_upload('/images/sample.jpg', 'text/xml')
          post :image_upload, :id => question.id, :image => @file
          response.should be_ok
          JSON.parse(response.body).should == { 'image_url' => question.reload.image.url(:thumb) }
        end
      end

      context "GET 'index'" do
        it "returns question IDs" do
          question = FactoryGirl.create(:question, :survey_id => survey.id)
          get :index, :survey_id => survey.id
          response.should be_ok
          JSON.parse(response.body).map { |hash| hash['id'] }.should include question.id
        end

        it "returns question types" do
          question = FactoryGirl.create(:question, :survey_id => survey.id, :type => "RadioQuestion")
          get :index, :survey_id => survey.id
          response.should be_ok
          JSON.parse(response.body).map { |hash| hash['type'] }.should include 'RadioQuestion'
        end

        it "returns all attributes of the question as well as the image_url" do
          question = RadioQuestion.create(FactoryGirl.attributes_for(:question, :survey_id => survey.id))
          get :index, :survey_id => survey.id
          response.should be_ok
          response.body.should include question.to_json(:methods => [:type, :image_url, :image_in_base64])
        end

        it "returns a :bad_request if no survey_id is passed" do
          get :index
          response.should_not be_ok
        end
      end

      context "GET 'show'" do
        it "returns the question as JSON" do
          question = FactoryGirl.create(:question, :survey => survey)
          get :show, :id => question.id
          response.should be_ok
          response.body.should == question.to_json(:methods => [:type, :image_url, :image_in_base64])
        end

        it "returns a :bad_request for an invalid question_id" do
          get :show, :id => 456787
          response.should_not be_ok
        end
      end
    end
  end
end

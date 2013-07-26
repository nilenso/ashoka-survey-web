require 'spec_helper'

module Api::V1
    describe ResponsesController do
      let(:organization_id) { 12 }

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
        let (:survey) { FactoryGirl.create(:survey, :organization_id => organization_id) }
        let (:question) { FactoryGirl.create(:question, :finalized) }

        it "creates an response" do
          resp = FactoryGirl.attributes_for(:response, :survey_id => survey.id, :answers_attributes =>{})
          expect {
            post :create, :response => resp, :user_id => 15, :organization_id => 42
          }.to change { Response.count }.by 1
        end

        it "creates the nested answers" do
          resp = FactoryGirl.attributes_for(:response, :survey_id => survey.id, :answers_attributes =>  { '0' => {'content' => 'asdasd', 'question_id' => question.id} })
          expect {
            post :create, :survey_id => survey.id, :response => resp, :user_id => 15, :organization_id => 42
          }.to change { Answer.count }.by 1
        end

        context "for photo uploading" do
          before(:each) { ImageUploader.storage = :file }

          it "accepts an image for a PhotoQuestion in Base64 format" do
            image = File.read 'spec/fixtures/images/sample.jpg'
            base64_image = Base64.encode64(image)
            resp = FactoryGirl.attributes_for(:response, :survey_id => survey.id, :answers_attributes =>  { '0' => {'question_id' => question.id, 'photo' => base64_image }})
            post :create, :survey_id => survey.id, :response => resp, :user_id => 15, :organization_id => 42
            answer = Answer.find_by_id(JSON.parse(response.body)['answers'][0]['id'])
            answer.photo.url.should_not =~ /missing/
          end
        end

        it "should return the newly created response with answers as JSON if it is incomplete" do
          resp = FactoryGirl.attributes_for(:response, :survey_id => survey.id, :answers_attributes =>  { '0' => {'content' => 'asdasd', 'question_id' => question.id} })
          post :create, :response => resp, :user_id => 15, :organization_id => 42
          response.should be_ok
          JSON.parse(response.body).keys.should =~ Response.new.attributes.keys.unshift("answers")
        end

        context "for a complete response" do
          it "should return the newly created response" do
            resp = FactoryGirl.attributes_for(:response, :survey_id => survey.id, :status => 'complete', :answers_attributes =>  { '0' => {'content' => 'asdasd', 'question_id' => question.id} })
            post :create, :response => resp, :user_id => 15, :organization_id => 42
            response.should be_ok
            JSON.parse(response.body).keys.should =~ Response.new.attributes.keys.unshift("answers")
          end

          it "should set the returned status to 'complete'" do
            resp = FactoryGirl.attributes_for(:response, :survey_id => survey.id, :status => 'complete', :answers_attributes =>  {})
            post :create, :response => resp, :user_id => 15, :organization_id => 42
            JSON.parse(response.body)['status'].should == Response::Status::COMPLETE
          end
        end


        it "should not create the response and should return it with answers if it fails the validation" do
          question = FactoryGirl.create(:question, :type => 'SingleLineQuestion', :mandatory => true)
          resp = FactoryGirl.attributes_for(:response, :survey_id => survey.id, :status => 'complete', :answers_attributes =>  { '0' => {'content' => "", 'question_id' => question.id} })
          expect {
              post :create, :response => resp, :user_id => 15, :organization_id => 42
          }.to change {Response.count}.by 0
          response.should_not be_ok
          response.status.should == 400
          JSON.parse(response.body).keys.should =~ Response.new.attributes.keys.unshift("answers")
        end

        it "returns the response with a bad_request if you give a invalid response" do
          resp = FactoryGirl.attributes_for(:response, :survey => nil, :answers_attributes =>  { '0' => {'content' => 'asdasd', 'question_id' => question.id} })
          post :create, :response => resp, :user_id => 15, :organization_id => 42
          response.should_not be_ok
          response.status.should == 400
        end

        it "sets the user_id and organization_id for the response" do
          resp = FactoryGirl.attributes_for(:response, :survey_id => survey.id, :user_id => 15, :organization_id => 42, :answers_attributes => {})
          post :create, :response => resp
          resp = Response.find_by_id(JSON.parse(response.body)['id'])
          resp.reload
          resp.user_id.should == 15
          resp.organization_id.should == 42
        end

        context "if the response exists" do
          before(:each) do
            FactoryGirl.create(:response, :survey => survey, :mobile_id => "foo123")
          end

          it "doesn't create a new response" do
            resp = FactoryGirl.attributes_for(:response, :survey_id => survey.id, :answers_attributes =>{})
            expect {
              post :create, :response => resp, :user_id => 15, :organization_id => 42, :mobile_id => "foo123"
            }.to change { Response.count }.by 0
          end

          it "returns the response as json" do
            resp = FactoryGirl.attributes_for(:response, :survey_id => survey.id, :status => 'complete', :answers_attributes =>  { '0' => {'content' => 'asdasd', 'question_id' => question.id} })
            post :create, :response => resp, :user_id => 15, :organization_id => 42, :mobile_id => "foo123"
            response.should be_ok
            JSON.parse(response.body).keys.should =~ Response.new.attributes.keys.unshift("answers")
          end
        end

        it "updates the response_id for its answers' records" do
          record = FactoryGirl.create :record, :response_id => nil
          answers_attrs = { '0' => { :content => 'AnswerFoo', :question_id => question.id, :record_id => record.id } }
          resp = FactoryGirl.attributes_for(:response, :survey_id => survey.id, :answers_attributes => answers_attrs)
          post :create, :response => resp, :user_id => 15, :organization_id => 42, :mobile_id => "foo123"
          record.reload.response_id.should_not be_nil
        end
      end

      context "PUT 'update'" do
        it "updates a response" do
          survey = FactoryGirl.create(:survey, :organization_id => organization_id)
          question = FactoryGirl.create(:question, :finalized)
          resp = FactoryGirl.create(:response, :survey => survey, :organization_id => organization_id, :user_id => 1)
          resp_attr = { :answers_attributes =>  { '0' => {'content' => 'asdasd', 'question_id' => question.id, 'updated_at' => Time.now.to_s} } }
          put :update, :id => resp.id, :response => resp_attr
          response.should be_ok
          Response.find(resp.id).answers.map(&:content).should include("asdasd")
        end

        it "returns a bad request if you give a invalid response" do
          survey = FactoryGirl.create(:survey, :organization_id => organization_id)
          question = FactoryGirl.create(:question, :mandatory => true)
          resp = FactoryGirl.create(:response, :survey => survey, :organization_id => organization_id, :user_id => 1, :status => 'complete')
          resp_attr = { :answers_attributes =>  { '0' => {'content' => nil, 'question_id' => question.id } } }
          put :update, :id => resp.id, :response => resp_attr
          response.should_not be_ok
          response.status.should == 400
        end

        it "updates only the answers which are newer than their corresponding answers in the DB" do
          survey = FactoryGirl.create(:survey, :organization_id => organization_id)
          question_1 = FactoryGirl.create(:question, :finalized)
          question_2 = FactoryGirl.create(:question, :finalized)
          resp = FactoryGirl.create(:response, :survey => survey, :organization_id => 1, :user_id => 1)
          resp.answers << FactoryGirl.create(:answer, :question_id => question_1.id)
          resp.answers << FactoryGirl.create(:answer, :question_id => question_2.id)
          resp_attr = { :answers_attributes =>
                        { '0' => {'content' => 'newer', 'question_id' => question_1.id, 'updated_at' => 5.hours.from_now.to_i, 'id' => resp.answers.first.id},
                          '1' => {'content' => 'older', 'question_id' => question_2.id, 'updated_at' => 5.hours.ago.to_i, 'id' => resp.answers.last.id }} }
          put :update, :id => resp.id, :response => resp_attr
          resp.reload.answers.map(&:content).should include 'newer'
          resp.reload.answers.map(&:content).should_not include 'older'
        end

        it "chooses whether to update the response status based on `updated_at`" do
          survey = FactoryGirl.create(:survey, :organization_id => organization_id)
          resp = FactoryGirl.create(:response, :organization_id => organization_id, :user_id => 1, :status => 'complete', :survey => survey)
          put :update, :id => resp.id, :response => { :status => 'incomplete', :answers_attributes => {}, 'updated_at' => 5.hours.ago.to_i }
          resp.reload.should be_complete
        end

        it "returns a 410 (GONE) if the response doesn't exist on the server anymore" do
          put :update, :id => 42, :response => { :status => 'incomplete', :answers_attributes => {}, :updated_at => 5.hours.ago.to_i }
          response.code.should == "410"
        end

        context "for photo uploading" do
          let(:survey) { FactoryGirl.create(:survey, :organization_id => 42) }
          it "accepts an image for a PhotoQuestion in Base64 format" do
            image = File.read 'spec/fixtures/images/sample.jpg'
            base64_image = Base64.encode64(image)
            resp = FactoryGirl.create(:response, :survey_id => survey.id)
            question = FactoryGirl.create :photo_question, :finalized, :survey => survey
            resp_attrs = FactoryGirl.attributes_for(:response, :id => resp.id, :survey_id => survey.id, :answers_attributes =>  { '0' => {'question_id' => question.id, 'photo' => base64_image }})
            put :update, :id => resp.id, :response => resp_attrs, :user_id => 15, :organization_id => 42
            answer = Answer.find_by_question_id_and_response_id(question.id, resp.id)
            answer.photo.url.should_not =~ /missing/
          end

          it "chooses whether to save the photo based on updated_at" do
            image = File.read 'spec/fixtures/images/sample.jpg'
            base64_image = Base64.encode64(image)
            photo = Rack::Test::UploadedFile.new('spec/fixtures/images/sample.jpg')
            photo.content_type = 'image/jpeg'
            question = FactoryGirl.create :photo_question, :finalized
            resp = FactoryGirl.create(:response, :survey_id => survey.id)
            answer = FactoryGirl.create(:answer, :response_id => resp.id, :question_id => question.id, :photo => photo)
            resp_attrs = FactoryGirl.attributes_for(:response, :id => resp.id, :survey_id => survey.id, :answers_attributes =>  { '0' => {'id' => answer.id, 'question_id' => question.id, 'photo' => base64_image, 'updated_at' => 5.days.ago.to_i }})
            old_filename = answer.photo.filename
            put :update, :id => resp.id, :response => resp_attrs, :user_id => 15, :organization_id => 42
            answer.reload.photo.filename.should == old_filename
          end
        end

        it "updates the response_id for its answers' records" do
          survey = FactoryGirl.create(:survey, :organization_id => 42)
          record = FactoryGirl.create :record, :response_id => nil
          question = FactoryGirl.create :question, :finalized, :survey => survey
          resp = FactoryGirl.create(:response, :survey => survey)

          answers_attrs = { '0' => { :content => 'AnswerFoo', :question_id => question.id, :record_id => record.id } }
          resp_attrs = FactoryGirl.attributes_for(:response, :id => resp.id, :answers_attributes => answers_attrs, :survey_id => survey.id)

          put :update, :id => resp.id, :response => resp_attrs
          record.reload.response_id.should_not be_nil
        end
      end

      context "GET 'show'" do
        let(:survey) { FactoryGirl.create :survey, :organization_id => 12 }

        it "returns the JSON version of the response" do
          resp = FactoryGirl.create(:response, :survey => survey, :organization_id => 12)
          get :show, :id => resp.id, :survey_id => survey.id
          response.should be_ok
          JSON.parse(response.body)['id'].should == resp.id
        end

        it "returns all the answers for a particular response" do
          resp = FactoryGirl.create(:response, :survey => survey)
          answer = FactoryGirl.create(:answer, :response => resp)
          another_answer = FactoryGirl.create(:answer, :response => resp)
          get :show, :id => resp.id, :survey_id => survey.id
          response.should be_ok
          answer_ids = JSON.parse(response.body)['answers'].map { |r| r['id'] }
          answer_ids.should =~ [answer.id, another_answer.id]
        end

        it "returns bad request if the response is not accessible to the current user" do
          sign_in_as('viewer')
          survey = FactoryGirl.create(:survey, :organization_id => 100)
          resp = FactoryGirl.create(:response, :survey => survey, :organization_id => 101)
          get :show, :id => resp.id, :survey_id => survey.id
          response.should_not be_ok
        end
      end

      context "GET 'count'" do
        let(:survey) { FactoryGirl.create :survey, :organization_id => 12 }

        it "returns number of responses available to the current user" do
          5.times { FactoryGirl.create(:response, :survey => survey, :organization_id => 12) }
          get :count, :survey_id => survey.id
          response.should be_ok
          JSON.parse(response.body)['count'].should == 5
        end

        it "returns bad request if the response is not accessible to the current user" do
          sign_in_as('viewer')
          survey = FactoryGirl.create(:survey, :organization_id => 100)
          resp = FactoryGirl.create(:response, :survey => survey, :organization_id => 101)
          get :show, :id => resp.id, :survey_id => survey.id
          response.should_not be_ok
        end
      end
    end
  end

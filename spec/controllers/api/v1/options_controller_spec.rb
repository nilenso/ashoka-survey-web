require 'spec_helper'

module Api
  module V1
    describe OptionsController do
      context "POST 'create'" do
        let(:survey) { FactoryGirl.create(:survey) }
        let(:question) { FactoryGirl.create(:question) }

        it "creates a new option" do
          option = FactoryGirl.attributes_for(:option)

          expect do
            post :create, :survey_id => survey.id, :question_id => question.id, :option => option
          end.to change { Option.count }.by(1)
        end

        it "responds with json" do
          option_hash = FactoryGirl.attributes_for(:option)
          post :create, :survey_id => survey.id, :question_id => question.id, :option => option_hash
          returned_json = JSON.parse(response.body)
          option_hash.each do |k,v|
            returned_json[k.to_s].should == v
          end
        end

        context "when create is unsuccessful" do
          it "returns the errors with a bad request status" do
            option_hash = FactoryGirl.attributes_for(:option)
            option_hash[:content] = ''
            post :create, :survey_id => survey.id, :question_id => question.id, :option => option_hash
            response.status.should == 400
            JSON.parse(response.body).should be_any { |m| m =~ /can\'t be blank/ }
          end
        end
      end

      context "PUT 'update'" do
        it "updates the option" do
          option = FactoryGirl .create(:option)
          put :update, :id => option.id, :option => {:content => "Hello"}
          response.should be_ok
          Option.find(option.id).content.should == "Hello"
        end

        it "responds with JSON" do
          option = FactoryGirl.create(:option)
          put :update, :id => option.id, :option => {:content => "Hello"}
          response.should be_ok
          lambda { JSON.parse(response.body) }.should_not raise_error(JSON::ParserError)
        end

        context "when update is unsuccessful" do
          it "returns the errors with a bad request status" do
            option = FactoryGirl.create(:option)
            put :update, :id => option.id, :option => {:content => ""}
            response.status.should == 400
            JSON.parse(response.body).should be_any { |m| m =~ /can\'t be blank/ }
          end
        end
      end

      context "DELETE 'destroy'" do
        it 'deletes the option' do
          option = FactoryGirl.create(:option)
          delete :destroy, :id => option.id
          Option.find_by_id(option.id).should be_nil
        end

        it "handles an invalid option id" do
          delete :destroy, :id => 2435678
          response.should_not be_ok
        end
      end

      context "GET 'index'" do
        it "returns all options for a question" do
          question = RadioQuestion.create(:content => "question with options")
          option = FactoryGirl.create(:option, :question => question)
          get :index, :question_id => question.id
          response.should be_ok
          JSON.parse(response.body).should include(JSON.parse(option.to_json))
        end

        it "returns a :bad_request for an invalid question ID" do
          get :index, :question_id => 123567
          response.should_not be_ok
        end

        it "returns nothing for a question without options" do
          pending "will have to be fixed with a QuestionWithOptions model"
          question = FactoryGirl.create(:question, :type => 'SingleLineQuestion')
          get :index, :question_id => question.id
          response.should be_ok
          JSON.parse(response.body).should be_empty
        end
      end
    end
  end
end

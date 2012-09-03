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
            JSON.parse(response.body)["content"].join.should =~ /can\'t be blank/
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
            JSON.parse(response.body)["content"].join.should =~ /can\'t be blank/
          end
        end
      end
    end
  end
end

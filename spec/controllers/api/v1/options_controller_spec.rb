require 'spec_helper'

module Api
  module V1
    describe OptionsController do
      let(:organization_id) { 12 }
      let(:survey) { FactoryGirl.create(:survey, :organization_id => organization_id) }
      let(:question) { FactoryGirl.create(:question, :survey => survey) }

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
        it "creates a new option" do
          option = FactoryGirl.attributes_for(:option, :question_id => question.id)

          expect do
            post :create, :survey_id => survey.id, :question_id => question.id, :option => option
          end.to change { Option.count }.by(1)
        end

        it "responds with json" do
          option_hash = FactoryGirl.attributes_for(:option, :question_id => question.id)
          post :create, :survey_id => survey.id, :question_id => question.id, :option => option_hash
          returned_json = JSON.parse(response.body)
          option_hash.each do |k,v|
            returned_json[k.to_s].should == v
          end
        end

        context "when create is unsuccessful" do
          it "returns the errors with a bad request status" do
            option_hash = FactoryGirl.attributes_for(:option, :question_id => question.id)
            option_hash[:content] = ''
            post :create, :survey_id => survey.id, :question_id => question.id, :option => option_hash
            response.status.should == 400
            JSON.parse(response.body).should be_any { |m| m =~ /can\'t be blank/ }
          end
        end

        it "doesn't allow creating the option if the current user doesn't have access to update the parent survey" do
          sign_in_as('viewer')
          option_hash = FactoryGirl.attributes_for(:option, :question_id => question.id)
          expect {
            post :create, :survey_id => survey.id, :question_id => question.id, :option => option_hash
          }.not_to change { Option.count }
          response.should_not be_ok
        end
      end

      context "PUT 'update'" do
        it "updates the option" do
          option = FactoryGirl.create(:option, :question => question)
          put :update, :id => option.id, :option => {:content => "Hello"}
          response.should be_ok
          Option.find(option.id).content.should == "Hello"
        end

        it "responds with JSON" do
          option = FactoryGirl.create(:option, :question => question)
          put :update, :id => option.id, :option => {:content => "Hello"}
          response.should be_ok
          lambda { JSON.parse(response.body) }.should_not raise_error(JSON::ParserError)
        end

        context "when update is unsuccessful" do
          it "returns the errors with a bad request status" do
            option = FactoryGirl.create(:option, :question => question)
            put :update, :id => option.id, :option => {:content => ""}
            response.status.should == 400
            JSON.parse(response.body).should be_any { |m| m =~ /can\'t be blank/ }
          end
        end

        it "doesn't allow updating the option if the current user doesn't have access to update the parent survey" do
          sign_in_as('viewer')
          option = FactoryGirl.create(:option, :question => question)
          put :update, :id => option.id, :option => {:content => "foo"}
          response.should_not be_ok
          option.reload.content.should_not == 'foo'
        end
      end

      context "DELETE 'destroy'" do
        it 'deletes the option' do
          option = FactoryGirl.create(:option, :question => question)
          delete :destroy, :id => option.id
          Option.find_by_id(option.id).should be_nil
        end

        it "handles an invalid option id" do
          delete :destroy, :id => 2435678
          response.should_not be_ok
        end

        it "doesn't allow destroying the option if the current user doesn't have access to update the parent survey" do
          sign_in_as('viewer')
          option = FactoryGirl.create(:option, :question => question)
          delete :destroy, :id => option.id
          response.should_not be_ok
          option.reload.should be_present
        end
      end
    end
  end
end

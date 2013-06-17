require 'spec_helper'

describe Api::V1::CategoriesController do
  before(:each) do
    sign_in_as('super_admin')
  end

  context "POST 'create'" do
    let(:survey) { FactoryGirl.create(:survey) }

    it "creates a new category in the database" do
      category_hash = FactoryGirl.attributes_for(:category, :survey_id => survey.id)
      expect {
        post :create, :category => category_hash
      }.to change { Category.count }.by 1
      response.should be_ok
    end

    it "creates a new category based on the type" do
      category_hash = FactoryGirl.attributes_for(:multi_record_category, :survey_id => survey.id)
      expect do
        post :create, :survey_id => survey.id, :category => category_hash
      end.to change { MultiRecordCategory.count }.by(1)
    end

    it "returns the created category as JSON, including the new ID" do
      category_hash = FactoryGirl.attributes_for(:category, :survey_id => survey.id)
      post :create, :category => category_hash
      created_category = JSON.parse(response.body)
      Category.find_by_id(created_category['id']).should be
      created_category.keys.should include(*Category.attribute_names)
    end

    it "returns the error message as JSON if save fails" do
      category = FactoryGirl.attributes_for(:category, :survey_id => survey.id, :content => nil)
      post :create, :category => category
      response.should_not be_ok
      JSON.parse(response.body).should include "Content can't be blank"
    end

    it "doesn't create the category if the current user doesn't have permission to do so" do
      sign_in_as('viewer')
      survey = FactoryGirl.create(:survey, :organization_id => 5)
      category = FactoryGirl.attributes_for(:category, :survey_id => survey.id, :type => 'MultiRecordCategory')
      expect {
        post :create, :survey_id => survey.id, :category => category
      }.not_to change { MultiRecordCategory.count }
    end
  end

  context "PUT 'update'" do
    it "updates the specified category" do
      category = FactoryGirl.create(:category, :order_number => 0, :content => "XYZ")
      put :update, :id => category.id, :category => { :content => "FOO", :order_number => 42 }
      response.should be_ok
      category.reload.content.should == "FOO"
      category.order_number.should == 42
    end

    it "returns the updated category as JSON" do
      category = FactoryGirl.create(:category, :order_number => 0, :content => "XYZ")
      put :update, :id => category.id, :category => { :content => "FOO", :order_number => 42 }
      updated_category = JSON.parse(response.body)
      updated_category['content'].should == "FOO"
      updated_category.keys.should include(*Category.attribute_names)
    end

    it "returns an error response if an invalid category id is supplied" do
      put :update, :id => 1234
      response.should_not be_ok
    end

    it "returns the error message as JSON if save fails" do
      category = FactoryGirl.create(:category)
      put :update, :id => category.id, :category => { :content => nil }
      response.should_not be_ok
      JSON.parse(response.body).should include "Content can't be blank"
    end

    it "doesn't update the category if the current user doesn't have permission to do so" do
      sign_in_as('viewer')
      survey = FactoryGirl.create(:survey, :organization_id => 5)
      category = FactoryGirl.create :category, :order_number => 0, :content => "XYZ", :survey => survey
      put :update, :id => category.id, :category => { :content => "FOO", :order_number => 42 }
      response.should_not be_ok
      category.content.should_not == "FOO"
    end
  end

  context "DELETE destroy" do
    it "should delete the category if the category is present" do
      category = FactoryGirl.create(:category)
      delete :destroy, :id => category.id
      response.should be_ok
      Category.find_by_id(category.id).should_not be
    end

    it "returns a 'bad request' if an invalid ID is specified" do
      delete :destroy, :id => 12345
      response.should_not be_ok
    end

    it "doesn't destroy the category if the current user doesn't have permission to do so" do
      sign_in_as('viewer')
      survey = FactoryGirl.create(:survey, :organization_id => 5)
      category = FactoryGirl.create :category, :order_number => 0, :content => "XYZ", :survey => survey
      put :destroy, :id => category.id
      response.should_not be_ok
      category.reload.should be_present
    end
  end

  context "GET 'show'" do
    it "returns the category as json including the sub-questions and sub-categories" do
      category = FactoryGirl.create(:category)
      category.categories << FactoryGirl.create(:category)
      category.questions << FactoryGirl.create(:question)
      get :show, :id => category.id
      response.should be_ok
      response.body.should == category.to_json(:include => [{ :questions => { :methods => :type }}, { :categories => { :methods => :type }}])
    end

    it "returns the type of each sub-category" do
      category = FactoryGirl.create(:category)
      category.categories << FactoryGirl.create(:category)
      get :show, :id => category.id
      response.should be_ok
      JSON.parse(response.body)['categories'][0].should have_key('type')
    end

    it "returns a 'bad_request' if the ID is invalid" do
      get :show, :id => 12355
      response.should_not be_ok
    end

    it "returns a bad response if the current user doesn't have access to the parent survey" do
      sign_in_as('viewer')
      survey = FactoryGirl.create(:survey, :organization_id => 5)
      category = FactoryGirl.create :category, :order_number => 0, :content => "XYZ", :survey => survey
      get :show, :id => category.id
      response.should_not be_ok
    end
  end

  context "POST 'duplicate'" do
    before(:each) do
      request.env["HTTP_REFERER"] = 'http://google.com'
    end

    context "when succesful" do
      it "creates new category" do
        category = FactoryGirl.create(:category)
        expect {
          post :duplicate, :id => category.id
        }.to change { Category.count }.by 1
      end

      it "redirects back with a success message" do
        category = FactoryGirl.create(:category)
        post :duplicate, :id => category.id
        response.should redirect_to(:back)
        flash[:notice].should_not be_nil
      end
    end

    context "when unsuccessful" do
      it "redirects back with a error message" do
        post :duplicate, :id => 456787
        response.should redirect_to(:back)
        flash[:error].should_not be_nil
      end
    end

    it "doesn't duplicate the category if the current user doesn't have access to the parent survey" do
      sign_in_as('viewer')
      survey = FactoryGirl.create(:survey, :organization_id => 5)
      category = FactoryGirl.create :category, :order_number => 0, :content => "XYZ", :survey => survey
      expect { post :duplicate, :id => category.id }.not_to change { Category.count }
      response.should_not be_ok
    end
  end
end

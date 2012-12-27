require 'spec_helper'

describe Api::V1::CategoriesController do
  before(:each) do
    sign_in_as('cso_admin')
  end
  context "POST 'create'" do
    it "creates a new category in the database" do
      category = FactoryGirl.attributes_for :category
      expect {
        post :create, :category => category
      }.to change { Category.count }.by 1
      response.should be_ok
    end

    it "returns the created category as JSON, including the new ID" do
      category = FactoryGirl.attributes_for :category
      post :create, :category => category
      created_category = JSON.parse(response.body)
      Category.find_by_id(created_category['id']).should be
      created_category.keys.should =~ Category.attribute_names
    end

    it "returns the error message as JSON if save fails" do
      category = FactoryGirl.attributes_for :category, :content => nil
      post :create, :category => category
      response.should_not be_ok
      JSON.parse(response.body).should include "Content can't be blank"
    end
  end

  context "PUT 'update'" do
    it "updates the specified category" do
      category = FactoryGirl.create :category, :order_number => 0, :content => "XYZ"
      put :update, :id => category.id, :category => { :content => "FOO", :order_number => 42 }
      response.should be_ok
      category.reload.content.should == "FOO"
      category.order_number.should == 42
    end

    it "returns the updated category as JSON" do
      category = FactoryGirl.create :category, :order_number => 0, :content => "XYZ"
      put :update, :id => category.id, :category => { :content => "FOO", :order_number => 42 }
      updated_category = JSON.parse(response.body)
      updated_category['content'].should == "FOO"
      updated_category.keys.should =~ Category.attribute_names
    end

    it "returns an error response if an invalid category id is supplied" do
      put :update, :id => 1234
      response.should_not be_ok
    end

    it "returns the error message as JSON if save fails" do
      category = FactoryGirl.create :category
      put :update, :id => category.id, :category => { :content => nil }
      response.should_not be_ok
      JSON.parse(response.body).should include "Content can't be blank"
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
  end

  context "GET 'index'" do
    it "returns the first level categories for a survey" do
      survey = FactoryGirl.create(:survey)
      survey.categories << FactoryGirl.create_list(:category, 4)
      get :index, :survey_id => survey.id
      response.should be_ok
      JSON.parse(response.body).size.should == 4
    end

    it "doesn't return nested categories" do
      survey = FactoryGirl.create(:survey)
      category = FactoryGirl.create(:category)
      survey.categories << category
      nested_category = FactoryGirl.create(:category)
      category.categories << nested_category
      get :index, :survey_id => survey.id
      JSON.parse(response.body).length.should == 1
    end

    it "returns a 'bad_request' if the survey ID is invalid" do
      get :index, :survey_id => 12355
      response.should_not be_ok
    end
  end

  context "GET 'show'" do
    it "returns the category as json including the sub-questions and sub-categories" do
      category = FactoryGirl.create(:category)
      category.categories << FactoryGirl.create(:category)
      category.questions << FactoryGirl.create(:question)
      get :show, :id => category.id
      response.should be_ok
      response.body.should == category.to_json(:include => [{ :questions => { :methods => :type }}, :categories])
    end

    it "returns a 'bad_request' if the ID is invalid" do
      get :show, :id => 12355
      response.should_not be_ok
    end
  end
end

require 'spec_helper'

describe Api::V1::CategoriesController do
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

    it "if save fails, it returns the error message as JSON" do
      category = FactoryGirl.attributes_for :category, :content => nil
      post :create, :category => category
      response.should_not be_ok
      JSON.parse(response.body).should include "Content can't be blank"
    end
  end
end

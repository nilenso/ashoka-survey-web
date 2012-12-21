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
end

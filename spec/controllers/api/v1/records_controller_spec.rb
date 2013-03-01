require 'spec_helper'

describe Api::V1::RecordsController do
  context "POST 'create'" do
    it "creates a record" do
      record_attrs = FactoryGirl.attributes_for(:record)
      expect {
        post :create, :record => record_attrs
      }.to change { Record.count }.by 1
    end

    it "returns the newly created record as json" do
      record_attrs = FactoryGirl.attributes_for(:record)
      post :create, :record => record_attrs
      response.should be_ok
      JSON.parse(response.body).except('created_at', 'updated_at').should == Record.last.as_json.except('created_at', 'updated_at')
    end

    it "returns an error code if the creation is not successful" do
      record_attrs = FactoryGirl.attributes_for(:record, :category_id => nil)
      post :create, :record => record_attrs
      response.should_not be_ok
    end
  end
end

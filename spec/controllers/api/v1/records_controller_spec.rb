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

  context "PUT 'update'" do
    it "returns a 410 if the record doesn't exist on the server anymore" do
      put :update, :id => 42
      response.code.should == "410"
    end

    it "returns the record if the record exists on the server" do
      record = FactoryGirl.create(:record)
      put :update, :id => record.id
      response.should be_ok
      JSON.parse(response.body).except('created_at', 'updated_at').should == record.as_json.except('created_at', 'updated_at')
    end
  end
end

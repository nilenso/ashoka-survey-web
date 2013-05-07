require 'spec_helper'

describe Reports::Excel::Metadata do
  let(:access_token) { access_token = mock(OAuth2::AccessToken) }

  context "when returning the metadata for a response" do
    before(:each) do
      names_response = mock(OAuth2::Response)
      access_token.stub(:get).with('/api/users/names_for_ids', :params => {:user_ids => [1].to_json}).and_return(names_response)
      names_response.stub(:parsed).and_return([{"id" => 1, "name" => "Bob"}])

      orgs_response = mock(OAuth2::Response)
      access_token.stub(:get).with('/api/organizations').and_return(orgs_response)
      orgs_response.stub(:parsed).and_return([{"id" => 1, "name" => "CSOOrganization"}, {"id" => 2, "name" => "Ashoka"}])
    end

    context "when the `disable_filtering` flag is false" do
      it "doesn't return the location of the response" do
        response = FactoryGirl.create(:response, :user_id => 1)
        metadata = Reports::Excel::Metadata.new([response], access_token, :disable_filtering => false)
        metadata.for(response).should_not include response.location
      end

      it "doesn't return the ip address of the response" do
        response = FactoryGirl.create(:response, :user_id => 1)
        metadata = Reports::Excel::Metadata.new([response], access_token, :disable_filtering => false)
        metadata.for(response).should_not include response.ip_address
      end
    end

    context "when the `disable_filtering` flag is true" do
      it "returns the location of the response" do
        response = FactoryGirl.create(:response, :user_id => 1)
        metadata = Reports::Excel::Metadata.new([response], access_token, :disable_filtering => true)
        metadata.for(response).should include response.location
      end

      it "returns the ip address of the response" do
        response = FactoryGirl.create(:response, :user_id => 1)
        metadata = Reports::Excel::Metadata.new([response], access_token, :disable_filtering => true)
        metadata.for(response).should include response.ip_address
      end
    end

    it "returns the `last_update` of the response" do
      response = FactoryGirl.create(:response, :user_id => 1)
      metadata = Reports::Excel::Metadata.new([response], access_token)
      metadata.for(response).should include response.last_update
    end

    it "returns the state of the response" do
      response = FactoryGirl.create(:response, :user_id => 1, :state => 'clean')
      metadata = Reports::Excel::Metadata.new([response], access_token)
      metadata.for(response).should include "clean"
    end

    it "returns the user name of the response" do
      response = FactoryGirl.create(:response, :user_id => 1)
      metadata = Reports::Excel::Metadata.new([response], access_token)
      metadata.for(response).should include "Bob"
    end

    it "returns the organization name of the response" do
      response = FactoryGirl.create(:response, :user_id => 1, :organization_id => 1)
      metadata = Reports::Excel::Metadata.new([response], access_token)
      metadata.for(response).should include "CSOOrganization"
    end
  end

  it "finds the user name for an ID" do
    names_response = mock(OAuth2::Response)
    access_token.stub(:get).with('/api/users/names_for_ids', :params => {:user_ids => [1].to_json}).and_return(names_response)
    names_response.stub(:parsed).and_return([{"id" => 1, "name" => "Bob"}])

    response = FactoryGirl.create(:response, :user_id => 1)
    metadata = Reports::Excel::Metadata.new([response], access_token)
    metadata.user_name_for(1).should == "Bob"
  end

  it "finds the organization name for an ID" do
    orgs_response = mock(OAuth2::Response)
    access_token.stub(:get).with('/api/organizations').and_return(orgs_response)
    orgs_response.stub(:parsed).and_return([{"id" => 1, "name" => "CSOOrganization"}, {"id" => 2, "name" => "Ashoka"}])

    metadata = Reports::Excel::Metadata.new([], access_token)
    metadata.organization_name_for(1).should == "CSOOrganization"
  end

  it "returns an empty string if an organization is not found" do
    orgs_response = mock(OAuth2::Response)
    access_token.stub(:get).with('/api/organizations').and_return(orgs_response)
    orgs_response.stub(:parsed).and_return([{"id" => 1, "name" => "CSOOrganization"}, {"id" => 2, "name" => "Ashoka"}])

    metadata = Reports::Excel::Metadata.new([], access_token)
    metadata.organization_name_for(42).should == ""
  end
end

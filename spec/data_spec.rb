require 'spec_helper'

describe Reports::Excel::Data do
  let(:survey) { FactoryGirl.create(:survey) }
  let(:access_token) { access_token = mock(OAuth2::AccessToken) }
  let(:server_url) { "http://example.com" }

  it "finds the user name for an ID" do
    names_response = mock(OAuth2::Response)
    access_token.stub(:get).with('/api/users/names_for_ids', :params => {:user_ids => [1].to_json}).and_return(names_response)
    names_response.stub(:parsed).and_return([{"id" => 1, "name" => "Bob"}])

    response = FactoryGirl.create(:response, :user_id => 1)
    data = Reports::Excel::Data.new(survey, [response], server_url, access_token)
    data.user_name_for(1).should == "Bob"
  end

  it "finds the organization name for an ID" do
    orgs_response = mock(OAuth2::Response)
    access_token.stub(:get).with('/api/organizations').and_return(orgs_response)
    orgs_response.stub(:parsed).and_return([{"id" => 1, "name" => "CSOOrganization"}, {"id" => 2, "name" => "Ashoka"}])

    data = Reports::Excel::Data.new(survey, [], server_url, access_token)
    data.organization_name_for(1).should == "CSOOrganization"
  end

  it "returns an empty string if an organization is not found" do
    orgs_response = mock(OAuth2::Response)
    access_token.stub(:get).with('/api/organizations').and_return(orgs_response)
    orgs_response.stub(:parsed).and_return([{"id" => 1, "name" => "CSOOrganization"}, {"id" => 2, "name" => "Ashoka"}])

    data = Reports::Excel::Data.new(survey, [], server_url, access_token)
    data.organization_name_for(42).should == ""
  end

  it "finds the filename from the survey" do
    data = Reports::Excel::Data.new(survey, [], server_url, access_token)
    data.file_name.should == survey.filename_for_excel
  end

  it "does not mutate the filename" do
    data = Reports::Excel::Data.new(survey, [], server_url, access_token)
    old_file_name = data.file_name
    Timecop.freeze(5.days.from_now) { data.file_name.should == old_file_name  }
  end

  it "doesn't mutate the filename after serializing/deserializing" do
    data_1 = Reports::Excel::Data.new(survey, [], server_url, "fooaccesstoken")
    data_2 = YAML::load(YAML::dump(data_1))
    data_1.file_name.should == Timecop.freeze(1.hour.from_now) { data_2.file_name }
  end
end

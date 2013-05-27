require "spec_helper"

describe OrganizationDecorator do
  it "fetches the number of surveys created by the organization" do
    organization = OrganizationDecorator.decorate(FactoryGirl.build(:organization))
    FactoryGirl.create_list(:survey, 5, :organization_id => organization.id)
    organization.survey_count.should == 5
  end

  context "when fetching responses for an organization" do
    it "fetches only non-blank responses" do
      organization = OrganizationDecorator.decorate(FactoryGirl.build(:organization))
      survey = FactoryGirl.create(:survey, :organization_id => organization.id)
      non_blank_response = FactoryGirl.create(:response, :survey => survey)
      blank_response = FactoryGirl.create(:response, :blank, :survey => survey)
      organization.response_count.should == 1
    end

    it "fetches public responses" do
      organization = OrganizationDecorator.decorate(FactoryGirl.build(:organization))
      public_survey = FactoryGirl.create(:survey, :public, :organization_id => organization.id)
      response = FactoryGirl.create(:response, :survey => public_survey, :organization_id => nil)
      organization.response_count.should == 1
    end
  end

  it "fetches the number of users in an organization" do
    users_response = mock(OAuth2::Response)
    access_token = mock(OAuth2::AccessToken)
    access_token.stub(:get).and_return(users_response)
    users_response.stub(:parsed).and_return([{"id" => 1, "name" => "Bob", "role" => 'field_agent'}])
    organization = OrganizationDecorator.decorate(FactoryGirl.build(:organization), :context => { :access_token => access_token })
    organization.user_count.should == 1
  end
end

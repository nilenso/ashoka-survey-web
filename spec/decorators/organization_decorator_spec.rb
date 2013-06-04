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


  context "when creating a chart of response counts grouped by month" do
    it "fetches the number of responses for an organization grouped by month of creation" do
      organization = OrganizationDecorator.decorate(FactoryGirl.build(:organization))
      survey = FactoryGirl.create(:survey, :organization_id => organization.id)
      Timecop.freeze("2013/04/15") { FactoryGirl.create(:response, :survey_id => survey.id) }
      Timecop.freeze("2013/05/15") { FactoryGirl.create(:response, :survey_id => survey.id) }
      Timecop.freeze("2013/05/16") { FactoryGirl.create(:response, :survey_id => survey.id) }
      organization.response_count_grouped_by_month.should =~ [["Apr 2013", 1], ["May 2013", 2]]
    end

    it "sorts the results by date" do
      organization = OrganizationDecorator.decorate(FactoryGirl.build(:organization))
      survey = FactoryGirl.create(:survey, :organization_id => organization.id)
      Timecop.freeze("2012/04/15") { FactoryGirl.create(:response, :survey_id => survey.id) }
      Timecop.freeze("2013/05/15") { FactoryGirl.create(:response, :survey_id => survey.id) }
      Timecop.freeze("2013/01/16") { FactoryGirl.create(:response, :survey_id => survey.id) }
      organization.response_count_grouped_by_month.should == [["Apr 2012", 1], ["Jan 2013", 1], ["May 2013", 1]]
    end

    it "excludes blank responses" do
      organization = OrganizationDecorator.decorate(FactoryGirl.build(:organization))
      survey = FactoryGirl.create(:survey, :organization_id => organization.id)
      FactoryGirl.create(:response, :blank, :survey_id => survey.id)
      organization.response_count_grouped_by_month.should == []
    end

    it "excludes responses belonging to surveys that don't belong to the current organization" do
      organization = OrganizationDecorator.decorate(FactoryGirl.build(:organization))
      survey = FactoryGirl.create(:survey, :organization_id => 12345)
      FactoryGirl.create(:response, :blank, :survey_id => survey.id)
      organization.response_count_grouped_by_month.should == []
    end
  end

  context "when creating a chart of survey counts grouped by month" do
    it "fetches the number of surveys created by an organization grouped by creation month" do
      organization = OrganizationDecorator.decorate(FactoryGirl.build(:organization))
      Timecop.freeze("2011/09/02") { FactoryGirl.create(:survey, :organization_id => organization.id) }
      Timecop.freeze("2012/04/05") { FactoryGirl.create(:survey, :organization_id => organization.id) }
      Timecop.freeze("2012/04/22") { FactoryGirl.create(:survey, :organization_id => organization.id) }
      organization.survey_count_grouped_by_month.should =~ [["Sep 2011", 1], ["Apr 2012", 2]]
    end

    it "sorts the results by date" do
      organization = OrganizationDecorator.decorate(FactoryGirl.build(:organization))
      Timecop.freeze("2012/04/15") { FactoryGirl.create(:survey, :organization_id => organization.id) }
      Timecop.freeze("2013/05/15") { FactoryGirl.create(:survey, :organization_id => organization.id) }
      Timecop.freeze("2013/01/16") { FactoryGirl.create(:survey, :organization_id => organization.id) }
      organization.survey_count_grouped_by_month.should == [["Apr 2012", 1], ["Jan 2013", 1], ["May 2013", 1]]
    end

    it "excludes surveys created by other organizations" do
      organization = OrganizationDecorator.decorate(FactoryGirl.build(:organization))
      survey = FactoryGirl.create(:survey, :organization_id => 54321)
      organization.survey_count_grouped_by_month.should == []
    end
  end

  context "when calculating asset space" do
    it "calculates the cumulative file size for questions and answers" do
      organization = OrganizationDecorator.decorate(FactoryGirl.build(:organization))
      survey = FactoryGirl.create(:survey, :organization_id => organization.id)
      response = FactoryGirl.create(:response, :survey => survey, :organization_id => organization.id)
      question = FactoryGirl.create(:question, :survey => survey, :photo_file_size => 2048)
      answer = FactoryGirl.create(:answer, :response => response, :photo_file_size => 1024)
      organization.asset_space_in_bytes.should == 3072
    end

    it "doesn't include questions and answers from other organizations" do
      organization = OrganizationDecorator.decorate(FactoryGirl.build(:organization))
      other_organization = OrganizationDecorator.decorate(FactoryGirl.build(:organization))
      survey = FactoryGirl.create(:survey, :organization_id => other_organization.id)
      response = FactoryGirl.create(:response, :survey => survey, :organization_id => other_organization.id)
      question = FactoryGirl.create(:question, :survey => survey, :photo_file_size => 2048)
      answer = FactoryGirl.create(:answer, :response => response, :photo_file_size => 1024)
      organization.asset_space_in_bytes.should == 0
    end

    it "outputs the asset size in a human readable format" do
      organization = OrganizationDecorator.decorate(FactoryGirl.build(:organization))
      survey = FactoryGirl.create(:survey, :organization_id => organization.id)
      response = FactoryGirl.create(:response, :survey => survey, :organization_id => organization.id)
      question = FactoryGirl.create(:question, :survey => survey, :photo_file_size => 2048)
      answer = FactoryGirl.create(:answer, :response => response, :photo_file_size => 1024)
      organization.asset_space_in_words.should == "3 KB"
    end
  end
end

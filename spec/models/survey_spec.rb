require 'spec_helper'

describe Survey do
  it { should respond_to :name }
  it { should respond_to :expiry_date }
  it { should respond_to :description }
  it { should respond_to :published }
  it { should respond_to :organization_id }
  it { should have_many(:questions).dependent(:destroy) }
  it { should have_many(:responses).dependent(:destroy) }
  it { should have_many(:survey_users).dependent(:destroy) }
  it { should have_many(:participating_organizations).dependent(:destroy) }
  it { should accept_nested_attributes_for :questions }
  it {should belong_to :organization }

  context "when validating" do
    it { should validate_presence_of :name }

    it "should not accept an invalid expiry date" do
      survey = FactoryGirl.build(:survey, :expiry_date => nil)
      survey.should_not be_valid
    end

    it "validates the expiry date to not be in the past" do
      date = Date.new(1990,10,24)
      survey = FactoryGirl.build(:survey, :expiry_date => date)
      survey.should_not be_valid
    end
  end

  context "when duplicating" do
    it "duplicates the nested associations as well" do
      survey = FactoryGirl.create :survey_with_questions
      survey.duplicate.questions.should_not be_empty
    end

    it "unpublishes the duplicated survey" do
      survey = FactoryGirl.create :survey_with_questions
      new_survey = survey.duplicate
      new_survey.should_not be_published
    end

    it "appends (copy) to the survey name" do
      survey = FactoryGirl.create :survey_with_questions
      new_survey = survey.duplicate
      new_survey.name.should =~ /\(copy\)/i
    end
  end

  context "publish" do
    it "should not be published by default" do
      survey = FactoryGirl.create(:survey)
      survey.should_not be_published
    end

    it "changes published to true" do
      survey = FactoryGirl.create(:survey)
      survey.publish
      survey.should be_published
    end
  end

  context "users" do
    it "returns a list of user-ids the survey is published to" do
      survey = FactoryGirl.create(:survey)
      survey_user = FactoryGirl.create(:survey_user, :survey_id => survey.id)
      survey.user_ids.should == [survey_user.user_id]
    end

    it "returns a list of users the survey is published to" do
      access_token = mock(OAuth2::AccessToken)
      users_response = mock(OAuth2::Response)
      users_response.stub(:parsed).and_return([{"id" => 1, "name" => "Bob"}, {"id" => 2, "name" => "John"}])
      access_token.stub(:get).with('/api/organizations/1/users').and_return(users_response)

      survey = FactoryGirl.create(:survey)
      user = { :id => 1, :name => "Bob"}
      FactoryGirl.create(:survey_user, :survey_id => survey.id, :user_id => user[:id])
      survey.users_for_organization(access_token, 1).map{|user| {:id => user.id, :name => user.name} }.should include user
      survey.users_for_organization(access_token, 1).map{|user| {:id => user.id, :name => user.name} }.should_not include({:id => 2, :name => "John"})
    end

    it "publishes survey to the given users" do
      survey = FactoryGirl.create(:survey)
      users = [1, 2]
      survey.publish_to_users(users)
      survey.user_ids.should == users
    end
  end

  context "participating organizations" do
    it "returns the ids of all participating organizations" do
      survey = FactoryGirl.create(:survey)
      participating_organization = FactoryGirl.create(:participating_organization, :survey_id => survey.id)
      survey.participating_organization_ids.should == [participating_organization.organization_id]
    end

    it "returns a list of organizations the survey is shared with" do
      access_token = mock(OAuth2::AccessToken)
      organizations_response = mock(OAuth2::Response)
      organizations_response.stub(:parsed).and_return([{"id" => 1, "name" => "CSOOrganization"}, {"id" => 2, "name" => "Org name"}])
      access_token.stub(:get).with('/api/organizations').and_return(organizations_response)

      survey = FactoryGirl.create(:survey)
      organization = { :id => 2, :name => "Org name"}
      FactoryGirl.create(:participating_organization, :survey_id => survey.id, :organization_id => organization[:id])
      survey.organizations(access_token, 1).map{|org| {:id => org.id, :name => org.name} }.should include organization
      survey.organizations(access_token, 1).map{|org| {:id => org.id, :name => org.name} }
      .should_not include({:id => 1, :name => "CSOOrganization"})
    end

    it "shares survey with the given organizations" do
      survey = FactoryGirl.create(:survey)
      organizations = [1, 2]
      survey.share_with_organizations(organizations)
      survey.participating_organization_ids.should == organizations
    end
  end

  it "returns a list of first level questions" do
    survey = FactoryGirl.create(:survey)
    question = RadioQuestion.create({content: "Untitled question", survey_id: survey.id, order_number: 1})
    question.options << Option.create(content: "Option", order_number: 2)
    nested_question = RadioQuestion.create({content: "Nested", survey_id: survey.id, order_number: 1, parent_id: question.options.first.id})
    survey.first_level_questions.should include question
    survey.first_level_questions.should_not include nested_question
  end
end

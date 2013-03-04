require 'spec_helper'

describe Survey do
  it { should respond_to :name }
  it { should respond_to :expiry_date }
  it { should respond_to :description }
  it { should respond_to :finalized }
  it { should respond_to :archived }
  it { should respond_to :organization_id }
  it { should respond_to :public }
  it { should respond_to(:auth_key) }
  it { should respond_to(:published_on) }
  it { should have_many(:questions).dependent(:destroy) }
  it { should have_many(:responses).dependent(:destroy) }
  it { should have_many(:categories).dependent(:destroy) }
  it { should have_many(:survey_users).dependent(:destroy) }
  it { should have_many(:participating_organizations).dependent(:destroy) }
  it { should accept_nested_attributes_for :questions }
  it { should belong_to :organization }
  it { should allow_mass_assignment_of(:public) }


  context "when validating" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :expiry_date }

    it "should not accept an invalid expiry date" do
      survey = FactoryGirl.build(:survey, :expiry_date => nil)
      survey.should_not be_valid
    end

    it "validates the expiry date to not be in the past" do
      date = Date.new(1990,10,24)
      survey = FactoryGirl.build(:survey, :expiry_date => date)
      survey.should_not be_valid
    end

    it "validates that the expiry_date can not updated to an older date" do
      survey = FactoryGirl.create(:survey, :expiry_date => Date.tomorrow.tomorrow)
      survey.update_attributes({:expiry_date => Date.today})
      survey.should_not be_valid
    end

    it "does not allow the description to be more than 250 characters" do
      long_description = '*' * 251
      survey = FactoryGirl.build(:survey, :description => long_description)
      survey.should_not be_valid
    end
  end

  context "when ordering" do
    it "fetches all draft surveys in descending order of created_at" do
      survey = FactoryGirl.create(:survey)
      another_survey = FactoryGirl.create(:survey)
      Survey.all.first(2).should == [another_survey, survey]
    end

    it "fetches all published surveys in descending order of published_on" do
      survey = FactoryGirl.create(:survey, :finalized => true, :published_on => (Date.today + 6.days) )
      another_survey = FactoryGirl.create(:survey, :finalized => true, :published_on => Date.today)
      draft_survey = FactoryGirl.create(:survey, :finalized => true)
      Survey.all.should == [survey, another_survey, draft_survey]
    end
  end

  it "provides the filename for the excel file" do
    survey = FactoryGirl.create(:survey)
    survey.filename_for_excel.should =~ /#{survey.name}/
    survey.filename_for_excel.should =~ /#{survey.id}/
    survey.filename_for_excel.should include Time.now.to_s
    survey.filename_for_excel.should =~ /.*xlsx$/
  end

  context "when duplicating" do
    it "duplicates the nested questions as well" do
      survey = FactoryGirl.create :survey_with_questions
      survey.duplicate.questions.should_not be_empty
    end

    it "duplicates the nested categories as well" do
      survey = FactoryGirl.create :survey_with_categories
      survey.duplicate.categories.should_not be_empty
    end

    it "doesn't duplicate the other associations" do
      survey = FactoryGirl.create :survey_with_questions
      SurveyUser.create(:survey_id => survey.id, :user_id => 5)
      survey.duplicate.survey_users.should be_empty
    end

    it "makes the duplicated survey a draft" do
      survey = FactoryGirl.create :survey_with_questions
      new_survey = survey.duplicate
      new_survey.should_not be_finalized
    end

    it "appends (copy) to the survey name" do
      survey = FactoryGirl.create :survey_with_questions
      new_survey = survey.duplicate
      new_survey.name.should =~ /\(copy\)/i
    end

    it "sets the published_on to nil" do
      survey = FactoryGirl.create :survey_with_questions, :published_on => Date.tomorrow
      new_survey = survey.duplicate
      new_survey.published_on.should == nil
    end

    it "saves the survey so it has an ID" do
      survey = FactoryGirl.create :survey_with_questions
      expect { survey.duplicate }.to change { Survey.count }.by 1
    end

    it "duplicates the questions and sub-questions, all with the survey ID of the new survey" do
      survey = FactoryGirl.create :survey
      radio_question = RadioQuestion.find(FactoryGirl.create(:question_with_options).id)
      survey.questions << radio_question
      radio_question.options[0].questions << FactoryGirl.create(:question, :survey_id => survey.id)
      new_survey = survey.duplicate
      new_survey.questions.count.should == 2
    end

    it "changes the survey's organization_id if necessary" do
      survey = FactoryGirl.create :survey_with_questions, :organization_id => 1
      new_survey = survey.duplicate(:organization_id => 42)
      new_survey.organization_id.should == 42
    end
  end

  context "finalize" do
    it "should not be finalized by default" do
      survey = FactoryGirl.create(:survey)
    survey.should_not be_finalized    end

    it "changes finalized to true" do
      survey = FactoryGirl.create(:survey)
      survey.finalize
      survey.should be_finalized
    end

    it "returns a list of draft surveys" do
      survey = FactoryGirl.create(:survey)
      another_survey = FactoryGirl.create(:survey, :finalized => true)
      Survey.drafts.should include(survey)
      Survey.drafts.should_not include(another_survey)
    end

    it "returns a list of finalized surveys" do
      survey = FactoryGirl.create(:survey)
      another_survey = FactoryGirl.create(:survey, :finalized => true)
      Survey.finalized.should_not include(survey)
      Survey.finalized.should include(another_survey)
    end

    it "returns a list of active surveys" do
      survey = FactoryGirl.create(:survey)
      another_survey = FactoryGirl.create(:survey, :finalized => true)
      other_survey = FactoryGirl.create(:survey, :archived => true)
      Survey.active.should_not include(survey)
      Survey.active.should_not include(other_survey)
      Survey.active.should include(another_survey)
    end

    it "returns a list of expired surveys" do
      survey = FactoryGirl.create(:survey)
      another_survey = FactoryGirl.create(:survey, :finalized => true)
      another_survey.update_column(:expiry_date, 5.days.ago)
      Survey.expired.should_not include(survey)
      Survey.expired.should include(another_survey)
    end

    it "returns a empty activerecord relation" do
      Survey.none.should be_empty
      Survey.none.should be_a ActiveRecord::Relation
    end
  end

  it "can be archived" do
    survey = FactoryGirl.create :survey
    survey.archive
    survey.reload.should be_archived
    survey.name.should =~ /\(Archived\)/
  end

  context "users" do
    it "returns a list of user-ids the survey is published to" do
      survey = FactoryGirl.create(:survey, :finalized => true)
      survey_user = FactoryGirl.create(:survey_user, :survey_id => survey.id)
      survey.user_ids.should == [survey_user.user_id]
    end

    it "returns a list of users the survey is published to and not published to" do
      access_token = mock(OAuth2::AccessToken)
      users_response = mock(OAuth2::Response)
      access_token.stub(:get).with('/api/organizations/1/users').and_return(users_response)
      users_response.stub(:parsed).and_return([{"id" => 1, "name" => "Bob", "role" => "field_agent"}, {"id" => 2, "name" => "John", "role" => "field_agent"}])

      survey = FactoryGirl.create(:survey, :finalized => true)
      FactoryGirl.create(:survey_user, :survey_id => survey.id, :user_id => 1)
      field_agents = survey.users_for_organization(access_token, 1)
      field_agents[:published].first.id.should == 1
      field_agents[:unpublished].first.id.should == 2
    end
  end

  context "participating organizations" do
    let(:survey) { FactoryGirl.create(:survey, :finalized => true) }
    it "returns the ids of all participating organizations" do
      participating_organization = FactoryGirl.create(:participating_organization, :survey_id => survey.id)
      survey.participating_organization_ids.should == [participating_organization.organization_id]
    end

    it "shares survey with the given organizations" do
      organizations = [1, 2]
      survey.share_with_organizations(organizations)
      survey.participating_organization_ids.should == organizations
    end

    it "doesn't allow sharing an un-finalized survey" do
      survey = FactoryGirl.create(:survey)
      organizations = [1, 2]
      survey.share_with_organizations(organizations)
      survey.participating_organization_ids.should == []
    end

    it "sets the published_on to the date on which it is published" do
      survey = FactoryGirl.create(:survey, :finalized => true)
      organizations = [3, 4]
      survey.share_with_organizations(organizations)
      survey.reload.published_on.should == Date.today
    end

    it "does not set the published_on date if it is already set" do
      survey = FactoryGirl.create(:survey, :finalized => true, :published_on => Date.yesterday)
      organizations = [3, 4]
      survey.share_with_organizations(organizations)
      survey.reload.published_on.should == Date.yesterday
    end

    it "returns partitioned organizations" do
      access_token = mock(OAuth2::AccessToken)
      organizations_response = mock(OAuth2::Response)
      organizations_response.stub(:parsed).and_return([{"id" => 1, "name" => "CSOOrganization"}, {"id" => 2, "name" => "Org name"}])
      access_token.stub(:get).with('/api/organizations').and_return(organizations_response)

      organization = { :id => 2, :name => "Org name"}
      FactoryGirl.create(:participating_organization, :survey_id => survey.id, :organization_id => organization[:id])
      partitioned_organizations = survey.partitioned_organizations(access_token)
      partitioned_organizations[:not_participating].first.id.should == 1
      partitioned_organizations[:participating].first.id.should == 2
    end
  end

  context "knows that its published" do

    it "if it is shared with at least one organization" do
      survey = FactoryGirl.create(:survey, :finalized => true)
      organizations = [1, 2]
      survey.share_with_organizations(organizations)
      survey.should be_published
    end

    it "if it is public" do
      survey = FactoryGirl.create(:survey, :finalized => true)
      survey.publicize
      survey.should be_published
    end

  end

  context "when finding children at the first level" do

    it "returns a list of first level questions" do
      survey = FactoryGirl.create(:survey)
      question = RadioQuestion.create({content: "Untitled question", survey_id: survey.id, order_number: 1})
      question.options << Option.create(content: "Option", order_number: 2)
      nested_question = RadioQuestion.create({content: "Nested", survey_id: survey.id, order_number: 1, parent_id: question.options.first.id})
      survey.first_level_questions.should include question
      survey.first_level_questions.should_not include nested_question
    end

    it "returns a list of first level categories" do
      survey = FactoryGirl.create(:survey)
      category = FactoryGirl.create :category
      survey.categories << category
      question = RadioQuestion.create({content: "Untitled question", survey_id: survey.id, order_number: 1})
      question.options << Option.create(content: "Option", order_number: 2)
      nested_category = Category.create({content: "Nested", survey_id: survey.id, order_number: 1, parent_id: question.options.first.id})
      survey.first_level_categories.should include category
      survey.first_level_categories.should_not include nested_category
    end

    it "returns the list of first_level_categories with sub questions" do
      survey = FactoryGirl.create(:survey)
      category = FactoryGirl.create :category
      survey.categories << category
      question = RadioQuestion.create({content: "Untitled question", survey_id: survey.id, order_number: 1, category_id: category.id})
      question.options << Option.create(content: "Option", order_number: 2)
      nested_category = Category.create({content: "Nested", survey_id: survey.id, order_number: 1, parent_id: question.options.first.id})
      survey.first_level_categories_with_questions.should include category
      survey.first_level_categories_with_questions.should_not include nested_category
    end

    it "returns a list of first level elements" do
      survey = FactoryGirl.create(:survey)
      question = RadioQuestion.create({content: "Untitled question", survey_id: survey.id, order_number: 1})
      question.options << Option.create(content: "Option", order_number: 2)
      nested_question = RadioQuestion.create({content: "Nested", survey_id: survey.id, order_number: 1, parent_id: question.options.first.id})
      category = FactoryGirl.create :category
      survey.categories << category
      question = RadioQuestion.create({content: "Untitled question", survey_id: survey.id, order_number: 1, category_id: category.id})
      question.options << Option.create(content: "Option", order_number: 2)
      nested_category = Category.create({content: "Nested", survey_id: survey.id, order_number: 1, parent_id: question.options.first.id})
      survey.first_level_elements.should =~ (survey.first_level_questions + survey.first_level_categories)
    end
  end

  context "reports" do
    it "finds all questions which have report data" do
      survey = FactoryGirl.create(:survey)
      question = RadioQuestion.find(FactoryGirl.create(:question_with_options, :survey_id => survey.id).id)
      another_question = RadioQuestion.find(FactoryGirl.create(:question_with_options, :survey_id => survey.id).id)
      5.times { question.answers << FactoryGirl.create(:answer_with_complete_response, :content => question.options.first.content) }
      3.times { question.answers << FactoryGirl.create(:answer_with_complete_response, :content => question.options.last.content) }
      survey.questions_with_report_data.should == [question]
    end
  end

  context "authorization key for public surveys" do
    it "contains a urlsafe random string" do
      survey = FactoryGirl.create :survey, :public => true
      survey.auth_key.should_not be_blank
      survey.auth_key.should =~ /[A-Za-z0-9\-_]+/
    end

    it "is nil for non public surveys" do
      survey = FactoryGirl.create :survey, :public => false
      survey.auth_key.should be_nil
    end

    it "is unique" do
      survey = FactoryGirl.create :survey, :auth_key => 'foo'
      dup_survey = FactoryGirl.build :survey, :auth_key => 'foo'
      dup_survey.should_not be_valid
      dup_survey.errors.full_messages.should include "Auth key has already been taken"
    end
  end

  it "checks whether the survey has expired" do
    survey = FactoryGirl.create(:survey)
    survey.update_attribute(:expiry_date, 2.days.ago)
    survey.should be_expired
    another_survey = FactoryGirl.create(:survey)
    another_survey.should_not be_expired
  end

  it "returns the number of complete responses" do
    survey = FactoryGirl.create(:survey, :finalized => true)
    6.times { FactoryGirl.create(:response, :survey => survey, :status => 'complete') }
    survey.complete_responses_count.should == 6
  end

  it "returns the number of incomplete responses" do
    survey = FactoryGirl.create(:survey, :finalized => true)
    6.times { FactoryGirl.create(:response, :survey => survey) }
    survey.incomplete_responses_count.should == 6
  end

  context "for scopes" do
    it "joins with the :questions table" do
      FactoryGirl.create_list(:survey_with_questions, 5)
      Survey.with_questions.count.should == (5 * 5)
    end

    it "returns a list of archived surveys" do
      archived_survey = FactoryGirl.create :survey, :archived => true
      another_archived_survey = FactoryGirl.create :survey, :archived => true
      survey = FactoryGirl.create :survey
      Survey.archived.should =~ [archived_survey, another_archived_survey]
    end
  end

  context "publicize" do
    it "makes the survey public" do
      survey = FactoryGirl.create(:survey, :finalized => true)
      survey.publicize()
      survey.reload.should be_public
    end

    it "updates the publisged on date forthe survey" do
      survey = FactoryGirl.create(:survey, :finalized => true)
      survey.publicize()
      survey.reload.published_on.should_not be_nil
    end
  end

  it "returns questions with at least one answer" do
    survey = FactoryGirl.create(:survey)
    question = FactoryGirl.create(:question, :survey => survey)
    question.answers << FactoryGirl.create(:answer)
    another_question = FactoryGirl.create(:question, :survey => survey)
    survey.questions << question
    survey.questions << another_question
    survey.questions_for_reports.should == [question]
  end

  it "returns the identifier questions" do
    survey = FactoryGirl.create(:survey)
    identifier_question = FactoryGirl.create :question, :identifier => true, :survey => survey
    normal_question = FactoryGirl.create :question, :identifier => false, :survey => survey
    survey.identifier_questions.should include identifier_question
    survey.identifier_questions.should_not include normal_question
  end
  it "gives you first five questions if there are no identfier questions " do
    survey = FactoryGirl.create(:survey)
    question = FactoryGirl.create :question, :identifier => false, :survey => survey
    survey.identifier_questions.should include question
  end

  it "publishes the survey if finalized" do
    survey = FactoryGirl.create(:survey, :finalized => true)
    survey.publish
    survey.published_on.should_not be_nil
  end
end

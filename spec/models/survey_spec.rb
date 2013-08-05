require 'spec_helper'

describe Survey do
  context "when validating" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :expiry_date }
    it { should ensure_length_of(:description).is_at_most(250) }

    context "validates the expiry date" do
      it "to not be in the past when survey is created" do
        date = Date.new(1990, 10, 24)
        survey = FactoryGirl.build(:survey, :expiry_date => date)
        survey.should_not be_valid
      end

      it "to not be in the past when expiry date is updated" do
        date = Date.new(1990, 10, 24)
        survey = FactoryGirl.create(:survey)
        survey.expiry_date = date
        survey.should_not be_valid
      end

      it "only when it is changed during a survey updation" do
        survey = Timecop.freeze(1.week.ago) { FactoryGirl.create(:survey, :expiry_date => 2.days.from_now) }
        survey.description = "foo"
        survey.should be_valid
      end
    end
  end

  context "when deleting a survey with associated elements" do
    it "deletes itself" do
      survey = FactoryGirl.create(:survey, :finalized)
      survey.delete_self_and_associated
      Survey.find_by_id(survey.id).should_not be_present
    end

    it "deletes finalized elements" do
      survey = FactoryGirl.create(:survey, :finalized)
      question = FactoryGirl.create(:question, :finalized, :survey => survey)
      category = FactoryGirl.create(:category, :finalized, :survey => survey)
      survey.delete_self_and_associated
      Question.find_by_id(question.id).should be_nil
      Category.find_by_id(category.id).should be_nil
    end

    it "deletes non-finalized elements" do
      survey = FactoryGirl.create(:survey)
      question = FactoryGirl.create(:question, :survey => survey)
      category = FactoryGirl.create(:category, :survey => survey)
      survey.delete_self_and_associated
      Question.find_by_id(question.id).should be_nil
      Category.find_by_id(category.id).should be_nil
    end

    it "deletes finalized options" do
      survey = FactoryGirl.create(:survey)
      FactoryGirl.create(:option)
      option = FactoryGirl.create(:option, :finalized, :question => FactoryGirl.create(:radio_question, :survey => survey))
      survey.delete_self_and_associated
      Option.find_by_id(option.id).should_not be_present
    end

    it "deletes non-finalized options" do
      survey = FactoryGirl.create(:survey)
      FactoryGirl.create(:option)
      option = FactoryGirl.create(:option, :question => FactoryGirl.create(:radio_question, :survey => survey))
      survey.delete_self_and_associated
      Option.find_by_id(option.id).should_not be_present
    end

    it "deletes the responses for the survey" do
      survey = FactoryGirl.create(:survey)
      response = FactoryGirl.create(:response, :survey => survey)
      survey.delete_self_and_associated
      Response.find_by_id(response.id).should_not be_present
    end

    it "deletes the answers of the survey" do
      survey = FactoryGirl.create(:survey)
      answer = FactoryGirl.create(:answer, :response => FactoryGirl.create(:response, :survey => survey))
      survey.delete_self_and_associated
      Answer.find_by_id(answer.id).should_not be_present
    end

    it "deletes the choices of the survey" do
      survey = FactoryGirl.create(:survey)
      answer = FactoryGirl.create(:answer, :response => FactoryGirl.create(:response, :survey => survey))
      choice = FactoryGirl.create(:choice, :answer => answer)
      survey.delete_self_and_associated
      Choice.find_by_id(choice.id).should_not be_present
    end

    it "deletes all records of the survey" do
      survey = FactoryGirl.create(:survey)
      record = FactoryGirl.create(:record, :response => FactoryGirl.create(:response, :survey => survey))
      survey.delete_self_and_associated
      Record.find_by_id(record.id).should_not be_present
    end

    context "for other surveys" do
      let(:another_survey) { FactoryGirl.create(:survey) }

      it "does not delete it" do
        survey = FactoryGirl.create(:survey, :finalized)
        survey.delete_self_and_associated
        Survey.find_by_id(another_survey.id).should be_present
      end

      it "does not delete finalized elements" do
        survey = FactoryGirl.create(:survey, :finalized)
        question = FactoryGirl.create(:question, :finalized, :survey => another_survey)
        category = FactoryGirl.create(:category, :finalized, :survey => another_survey)
        survey.delete_self_and_associated
        Question.find_by_id(question.id).should_not be_nil
        Category.find_by_id(category.id).should_not be_nil
      end

      it "does not delete non-finalized elements" do
        survey = FactoryGirl.create(:survey)
        question = FactoryGirl.create(:question, :survey => another_survey)
        category = FactoryGirl.create(:category, :survey => another_survey)
        survey.delete_self_and_associated
        Question.find_by_id(question.id).should_not be_nil
        Category.find_by_id(category.id).should_not be_nil
      end

      it "does not delete finalized options" do
        survey = FactoryGirl.create(:survey)
        FactoryGirl.create(:option)
        option = FactoryGirl.create(:option, :finalized, :question => FactoryGirl.create(:radio_question, :survey => another_survey))
        survey.delete_self_and_associated
        Option.find_by_id(option.id).should be_present
      end

      it "does not delete non-finalized options" do
        survey = FactoryGirl.create(:survey)
        FactoryGirl.create(:option)
        option = FactoryGirl.create(:option, :question => FactoryGirl.create(:radio_question, :survey => another_survey))
        survey.delete_self_and_associated
        Option.find_by_id(option.id).should be_present
      end

      it "does not delete the responses" do
        survey = FactoryGirl.create(:survey)
        response = FactoryGirl.create(:response, :survey => another_survey)
        survey.delete_self_and_associated
        Response.find_by_id(response.id).should be_present
      end

      it "does not delete the answers" do
        survey = FactoryGirl.create(:survey)
        answer = FactoryGirl.create(:answer, :response => FactoryGirl.create(:response, :survey => another_survey))
        survey.delete_self_and_associated
        Answer.find_by_id(answer.id).should be_present
      end

      it "does not delete the choices" do
        survey = FactoryGirl.create(:survey)
        answer = FactoryGirl.create(:answer, :response => FactoryGirl.create(:response, :survey => another_survey))
        choice = FactoryGirl.create(:choice, :answer => answer)
        survey.delete_self_and_associated
        Choice.find_by_id(choice.id).should be_present
      end

      it "does not delete records" do
        survey = FactoryGirl.create(:survey)
        record = FactoryGirl.create(:record, :response => FactoryGirl.create(:response, :survey => another_survey))
        survey.delete_self_and_associated
        Record.find_by_id(record.id).should be_present
      end
    end
  end

  it "provides the filename for the excel file" do
    survey = FactoryGirl.create(:survey)
    survey.filename_for_excel.should =~ /#{survey.name}/
    survey.filename_for_excel.should =~ /#{survey.id}/
    survey.filename_for_excel.should include Time.now.strftime("%Y-%m-%d %I.%M.%S%P")
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

    it "saves the survey with archived false when duplicating an archived survey" do
      survey = FactoryGirl.create(:survey, :archived, :organization_id => 1)
      new_survey = survey.duplicate
      new_survey.should_not be_archived
    end
  end

  context "finalize" do
    it "should not be finalized by default" do
      survey = FactoryGirl.create(:survey)
      survey.should_not be_finalized
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

    it "returns a empty activerecord relation" do
      Survey.none.should be_empty
      Survey.none.should be_a ActiveRecord::Relation
    end
  end

  context "when finalizing" do
    it "changes finalized to true" do
      survey = FactoryGirl.create(:survey)
      survey.finalize
      survey.should be_finalized
    end

    it "finalizes its questions" do
      survey = FactoryGirl.create(:survey)
      question = FactoryGirl.create(:question, :survey => survey)
      survey.finalize
      question.reload.should be_finalized
    end

    it "finalizes its options" do
      survey = FactoryGirl.create(:survey)
      radio_question = FactoryGirl.create(:radio_question, :survey => survey)
      option = FactoryGirl.create(:option, :question => radio_question)
      survey.finalize
      option.reload.should be_finalized
    end

    it "finalizes its categories" do
      survey = FactoryGirl.create(:survey)
      category = FactoryGirl.create(:category, :survey => survey)
      survey.finalize
      category.reload.should be_finalized
    end
  end

  context "archive" do
    it "can be archived" do
      survey = FactoryGirl.create(:survey, :finalized => true)
      survey.archive
      survey.reload
      survey.should be_archived
      survey.name.should =~ /\(Archived\)/
    end

    it "cannot be archived if the survey is not finalized" do
      survey = FactoryGirl.create(:survey, :finalized => false)
      survey.archive
      survey.should_not be_valid
      survey.reload.should_not be_archived
      survey.should have(1).error
    end
  end

  it "finds all its options" do
    survey = FactoryGirl.create(:survey)
    option_1 = FactoryGirl.create(:option, :question => FactoryGirl.create(:radio_question, :survey => survey))
    option_2 = FactoryGirl.create(:option, :question => FactoryGirl.create(:radio_question, :survey => survey, :parent => option_1))
    option_3 = FactoryGirl.create(:option)
    survey.options.should =~ [option_1, option_2]
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

    context "when finding users who have taken a response to this survey" do
      it "returns a list of user IDs" do
        survey = FactoryGirl.create(:survey)
        response = FactoryGirl.create(:response, :user_id => 5, :survey => survey)
        survey.ids_for_users_with_responses.should == [5]
      end

      it "doesn't include users who haven't taken a response to this survey" do
        survey = FactoryGirl.create(:survey)
        other_survey = FactoryGirl.create(:survey)
        response = FactoryGirl.create(:response, :user_id => 5, :survey => other_survey)
        survey.ids_for_users_with_responses.should == []
      end

      it "doesn't include duplicate users" do
        survey = FactoryGirl.create(:survey)
        FactoryGirl.create(:response, :user_id => 5, :survey => survey)
        FactoryGirl.create(:response, :user_id => 5, :survey => survey)
        survey.ids_for_users_with_responses.should == [5]
      end
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
      organizations_response.stub(:parsed).and_return([
        {"id" => 1, "name" => "CSOOrganization", "logos" => {"thumb_url" => "http://foo.com/bar.png"}},
        {"id" => 2, "name" => "Org name", "logos" => {"thumb_url" => "http://foo.com/bar.png"}}
      ])
      access_token.stub(:get).with('/api/organizations').and_return(organizations_response)

      organization = {:id => 2, :name => "Org name"}
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
      category = FactoryGirl.create(:category, :survey => survey)
      question = RadioQuestion.create({content: "Untitled question", survey_id: survey.id, order_number: 1})
      question.options << Option.create(content: "Option", order_number: 2)
      nested_category = Category.create({content: "Nested", survey_id: survey.id, order_number: 1, parent_id: question.options.first.id})
      survey.first_level_categories.should include category
      survey.first_level_categories.should_not include nested_category
    end

    it "returns the list of first_level_categories with sub questions" do
      survey = FactoryGirl.create(:survey)
      category = FactoryGirl.create(:category, :survey => survey)
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
      category = FactoryGirl.create :category, :survey => survey
      question = RadioQuestion.create({content: "Untitled question", survey_id: survey.id, order_number: 1, category_id: category.id})
      question.options << Option.create(content: "Option", order_number: 2)
      nested_category = Category.create({content: "Nested", survey_id: survey.id, order_number: 1, parent_id: question.options.first.id})
      survey.first_level_elements.should =~ (survey.first_level_questions + survey.first_level_categories)
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

    it "doesn't change after it is first generated" do
      survey = FactoryGirl.create :survey, :public => true
      old_auth_key = survey.auth_key
      survey.save
      survey.auth_key.should == old_auth_key
    end
  end

  it "checks whether the survey has expired" do
    survey = FactoryGirl.create(:survey)
    survey.update_attribute(:expiry_date, 2.days.ago)
    survey.should be_expired
    another_survey = FactoryGirl.create(:survey)
    another_survey.should_not be_expired
  end

  context "when counting responses" do
    it "returns the number of complete responses accessible by the current user" do
      survey = FactoryGirl.create(:survey, :finalized => true)
      6.times { FactoryGirl.create(:response, :survey => survey, :status => 'complete', :user_id => 123) }
      FactoryGirl.create(:response, :survey => survey, :status => 'complete', :user_id => 456)
      survey.responses.should_receive(:accessible_by).and_return(Response.where(:user_id => 123))
      survey.complete_responses_count(stub).should == 6
    end

    it "returns the number of incomplete responses accessible by the current user" do
      survey = FactoryGirl.create(:survey, :finalized => true)
      6.times { FactoryGirl.create(:response, :survey => survey, :user_id => 123) }
      FactoryGirl.create(:response, :survey => survey, :user_id => 456)
      survey.responses.should_receive(:accessible_by).and_return(Response.where(:user_id => 123))
      survey.incomplete_responses_count(stub).should == 6
    end

    it "excludes blank responses" do
      survey = FactoryGirl.create(:survey, :finalized => true)
      2.times { FactoryGirl.create(:response, :survey => survey, :user_id => 123, :blank => true) }
      2.times { FactoryGirl.create(:response, :survey => survey, :status => 'complete', :user_id => 123, :blank => true) }
      survey.responses.should_receive(:accessible_by).twice.and_return(Response.where(:user_id => 123))
      survey.incomplete_responses_count(stub).should == 0
      survey.complete_responses_count(stub).should == 0
    end
  end

  context "for scopes" do
    it "joins with the :questions table" do
      FactoryGirl.create_list(:survey_with_questions, 5)
      Survey.with_questions.count.should == (5 * 5)
    end

    it "returns a list of archived surveys" do
      archived_survey = FactoryGirl.create(:survey, :archived)
      another_archived_survey = FactoryGirl.create(:survey, :archived)
      unarchived_survey = FactoryGirl.create(:survey)
      Survey.archived.should =~ [archived_survey, another_archived_survey]
    end

    it "returns a list of expired surveys" do
      survey = FactoryGirl.create(:survey)
      expired_survey = Timecop.freeze(1.week.ago) { FactoryGirl.create(:survey, :finalized => true, :expiry_date => 2.days.from_now) }
      Survey.expired.should == [expired_survey]
    end

    it "returns a list of unarchived surveys" do
      archived_survey = FactoryGirl.create(:survey, :archived)
      unarchived_survey = FactoryGirl.create(:survey, :archived => false)
      Survey.unarchived.should == [unarchived_survey]
    end

    context "active" do
      it "returns finalized surveys" do
        draft_survey = FactoryGirl.create(:survey, :finalized => false)
        finalized_survey = FactoryGirl.create(:survey, :finalized => true)
        Survey.active.should == [finalized_survey]
      end

      it "return unarchived surveys" do
        archived_survey = FactoryGirl.create(:survey, :archived => true, :finalized => true)
        unarchived_survey = FactoryGirl.create(:survey, :archived => false, :finalized => true)
        Survey.active.should == [unarchived_survey]
      end

      it "returns unexpired surveys" do
        expired_survey = FactoryGirl.create(:survey, :expiry_date => 5.days.from_now, :finalized => true)
        unexpired_survey = FactoryGirl.create(:survey, :expiry_date => 10.days.from_now, :finalized => true)
        Timecop.freeze(7.days.from_now) do
          Survey.active.should == [unexpired_survey]
        end
      end

      it "returns surveys that expire today" do
        time_right_now = Time.parse("2013-07-10 15:50")
        survey = Timecop.freeze(time_right_now - 5.days) do
          FactoryGirl.create(:survey, :finalized, :expiry_date => time_right_now.to_date)
        end
        Timecop.travel(time_right_now)
        Survey.active.should == [survey]
      end
    end

    context "active_plus" do
      it "returns the active surveys along with the extra surveys passed in" do
        active_survey = FactoryGirl.create(:survey, :finalized => true)
        inactive_survey = FactoryGirl.create(:survey, :finalized => false)
        Survey.active_plus([inactive_survey.id]).should =~ [active_survey, inactive_survey]
      end
    end

    context "ordering" do
      it "orders published surveys in the most recently published fashion" do
        oldest_survey = Timecop.freeze(2.days.from_now) { FactoryGirl.create(:survey, :public, :published_on => Date.today) }
        old_survey = Timecop.freeze(1.week.from_now) { FactoryGirl.create(:survey, :public, :published_on => Date.today) }
        new_survey = Timecop.freeze(2.weeks.from_now) { FactoryGirl.create(:survey, :public, :published_on => Date.today) }
        Survey.most_recent.should == [new_survey, old_survey, oldest_survey]
      end

      it "orders unpublished surveys in the most recently created fashion" do
        oldest_survey = Timecop.freeze(2.days.from_now) { FactoryGirl.create(:survey, :published_on => nil) }
        old_survey = Timecop.freeze(1.week.from_now) { FactoryGirl.create(:survey, :published_on => nil) }
        new_survey = Timecop.freeze(2.weeks.from_now) { FactoryGirl.create(:survey, :published_on => nil) }
        Survey.most_recent.should == [new_survey, old_survey, oldest_survey]
      end

      it "orders unpublished surveys after published surveys" do
        oldest_published_survey = Timecop.freeze(2.days.from_now) { FactoryGirl.create(:survey, :public, :published_on => Date.today) }
        old_published_survey = Timecop.freeze(1.week.from_now) { FactoryGirl.create(:survey, :public, :published_on => Date.today) }
        new_unpublished_survey = Timecop.freeze(2.weeks.from_now) { FactoryGirl.create(:survey, :published_on => nil) }
        Survey.most_recent.should == [old_published_survey, oldest_published_survey, new_unpublished_survey]
      end
    end
  end

  context "publicize" do
    it "makes the survey public" do
      survey = FactoryGirl.create(:survey, :finalized => true)
      survey.publicize
      survey.reload.should be_public
    end

    it "updates the publisged on date forthe survey" do
      survey = FactoryGirl.create(:survey, :finalized => true)
      survey.publicize
      survey.reload.published_on.should_not be_nil
    end
  end

  it "returns questions with at least one answer of a complete response" do
    survey = FactoryGirl.create(:survey)
    question = FactoryGirl.create(:question, :finalized, :survey => survey)
    resp = FactoryGirl.create(:response, :status => 'complete', :state => 'clean')
    FactoryGirl.create(:answer, :response => resp, :question => question)
    another_question = FactoryGirl.create(:question, :survey => survey)
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

  context "#elements_in_order_as_json" do
    it "should include all the elements of the survey" do
      survey = FactoryGirl.create :survey
      question = FactoryGirl.create :question, :survey => survey
      category = FactoryGirl.create :category, :survey => survey
      category.questions << FactoryGirl.create(:question)
      survey.elements_in_order_as_json.size.should == 2
    end
  end

  context "#ordered_question_tree" do
    it "should include all the elements of the survey" do
      survey = FactoryGirl.create :survey
      question = FactoryGirl.create :question, :survey => survey
      category = FactoryGirl.create :category, :survey => survey
      sub_question = FactoryGirl.create(:question)
      category.questions << sub_question
      survey.ordered_question_tree.should =~ [question, sub_question]
    end
  end

  context "when finding or initializing answers for a response" do
    it "initializes answers for questions at every level of the survey" do
      survey = FactoryGirl.create(:survey)
      question = FactoryGirl.create(:radio_question, :survey => survey)
      sub_question = FactoryGirl.create(:question, :survey => survey, :parent => FactoryGirl.create(:option, :question => question))
      response = FactoryGirl.create(:response, :survey => survey)
      answers = survey.find_or_initialize_answers_for_response(response)
      answers.map(&:question_id).should =~ [question.id, sub_question.id]
    end

    it "doesn't create any answers" do
      survey = FactoryGirl.create(:survey)
      question = FactoryGirl.create(:question, :survey => survey)
      response = FactoryGirl.create(:response, :survey => survey)
      expect { survey.find_or_initialize_answers_for_response(response) }.not_to change { Answer.count }
    end

    it "returns existing answers (if any)" do
      survey = FactoryGirl.create(:survey)
      question = FactoryGirl.create(:question, :finalized, :survey => survey)
      response = FactoryGirl.create(:response, :survey => survey)
      answer = FactoryGirl.create(:answer, :response => response, :question => question)
      survey.find_or_initialize_answers_for_response(response).should == [answer]
    end
  end
end

require 'spec_helper'

describe Response do
  it { should validate_presence_of(:survey_id) }
  it { should validate_presence_of(:organization_id) }
  it { should validate_presence_of(:user_id) }

  it "doesn't allow changing back from complete to incomplete" do
    response = FactoryGirl.create(:response, :complete)
    response.status = Response::Status::INCOMPLETE
    response.should_not be_valid
  end

  context "scopes" do
    it "returns responses in the chronological order" do
      old_response = Timecop.freeze(5.days.ago) { FactoryGirl.create(:response) }
      new_response = Timecop.freeze(5.days.from_now) { FactoryGirl.create(:response) }
      Response.earliest_first.should == [old_response, new_response]
    end

    it "returns complete responses" do
      complete_response = FactoryGirl.create(:response, :status => "complete")
      incomplete_response = FactoryGirl.create(:response, :status => "incomplete")
      Response.completed.should == [complete_response]
    end

    context "created_between" do
      it "returns responses in a date range" do
        from, to = (10.days.ago), (5.days.ago)
        response_before_range = Timecop.freeze(15.days.ago) { FactoryGirl.create(:response) }
        response_within_range = Timecop.freeze(7.days.ago) { FactoryGirl.create(:response) }
        response_after_range = Timecop.freeze(2.days.ago) { FactoryGirl.create(:response) }
        Response.created_between(from, to).should == [response_within_range]
      end

      it "includes responses created at the from and to dates" do
        from, to = (Date.parse("2013/05/05")), (Date.parse("2013/05/10"))
        from_date_response = Timecop.freeze(from) { FactoryGirl.create(:response) }
        to_date_response = Timecop.freeze(to) { FactoryGirl.create(:response) }
        Response.created_between(from, to).should =~ [from_date_response, to_date_response]
      end
    end
  end

  context "callbacks" do
    it "sets the completed_at date when the state changes to complete" do
      response = FactoryGirl.create(:response, :incomplete)
      response.status = "complete"
      current_time = Time.zone.now
      Timecop.freeze(current_time) { response.save }
      response.reload.completed_at.to_i.should == current_time.to_i
    end

    it "doesn't set the completed_at date when the state isn't complete" do
      response = FactoryGirl.create(:response, :incomplete)
      response.status = "incomplete"
      response.save
      response.reload.completed_at.should be_nil
    end

    it "doesn't change the completed_at date when the state stays complete" do
      current_time = Time.zone.now
      response = Timecop.freeze(current_time) { FactoryGirl.create(:response, :complete) }
      response.status = "complete"
      response.save
      response.reload.completed_at.to_i.should == current_time.to_i
    end
  end

  it "merges the response status based on updated_at" do
    response = FactoryGirl.create :response, :organization_id => 1, :user_id => 1, :status => 'complete'
    response.merge_status({:status => 'incomplete', :updated_at => 5.days.ago.to_s})
    response.should be_complete
    response.merge_status({:status => 'incomplete', :updated_at => 5.days.from_now.to_s})
    response.should be_incomplete
  end

  it "doesn't require a user_id and organization_id if it's survey is public" do
    survey = FactoryGirl.create :survey, :public => true
    response = Response.new(:survey => survey)
    response.should be_valid
  end

  context "when finding the time of the last update" do
    it "looks through the `updated_at` for all its answers" do
      response = FactoryGirl.create :response, :updated_at => 2.days.from_now
      answer = FactoryGirl.create(:answer)
      response.answers << answer
      time = 5.days.from_now
      answer.update_attribute :updated_at, time
      response.last_update.to_i.should == time.to_i
    end

    it "looks at the response's `updated_at` as well" do
      time = 2.days.from_now
      response = FactoryGirl.create :response, :updated_at => time
      response.answers << FactoryGirl.create(:answer)
      response.last_update.to_i.should == time.to_i
    end

    it "doesn't complain if the response has no answers" do
      response = FactoryGirl.create :response
      expect { response.last_update }.not_to raise_error
    end
  end

  context "when marking a response incomplete" do
    it "marks the response incomplete" do
      survey = FactoryGirl.create(:survey)
      response = FactoryGirl.create(:response, :survey => survey, :organization_id => 1, :user_id => 1)
      response.incomplete
      response.reload.should be_incomplete
    end

    it "marks response complete" do
      survey = FactoryGirl.create(:survey)
      response = FactoryGirl.create(:response, :survey => survey)
      response.complete
      response.reload.should be_complete
    end
  end

  context "when creating a valid response from params" do
    let (:survey) { FactoryGirl.create(:survey) }
    let (:question) { FactoryGirl.create(:question, :finalized) }

    it "creates a response" do
      resp = FactoryGirl.build(:response, :survey_id => survey.id, :organization_id => 42, :user_id => 50)
      expect {
        resp.create_response({:answers_attributes => {}})
      }.to change { Response.count }.by 1
    end

    it "creates the nested answers" do
      resp = FactoryGirl.build(:response, :survey_id => survey.id, :organization_id => 42, :user_id => 50)
      answers_attributes = {'0' => {:content => 'asdasd', :question_id => question.id}}
      expect {
        resp.create_response({:answers_attributes => answers_attributes})
      }.to change { Answer.count }.by 1
    end

    it "should not increase the response count if the answers are invalid" do
      question = FactoryGirl.create(:question, :finalized, :max_length => 2, :survey => survey)
      resp = FactoryGirl.build(:response, :survey_id => survey.id, :organization_id => 42, :user_id => 50)
      answers_attributes = {'0' => {:content => 'abcd', :question_id => question.id}}
      expect {
        resp.create_response({:answers_attributes => answers_attributes})
      }.to_not change { Response.count }
    end

    it "should not increase the response count if saving the answers fails" do
      question = FactoryGirl.create(:question, :finalized, :max_length => 2)
      resp = FactoryGirl.build(:response, :survey_id => survey.id, :organization_id => 42, :user_id => 50)
      answers_attributes = {'0' => {:content => 'abcde', :question_id => question.id}}
      expect {
        resp.create_response({:answers_attributes => answers_attributes})
      }.to_not change { Response.count }
    end

    context "return values" do
      it "returns true if valid response" do
        resp = FactoryGirl.build(:response, :survey_id => survey.id, :organization_id => 42, :user_id => 50)
        resp.create_response({:answers_attributes => {}}).should be_true
      end

      it "returns false for an invalid response" do
        question = FactoryGirl.create(:single_line_question, :finalized, :max_length => 2)
        resp = FactoryGirl.build(:response, :survey_id => survey.id)
        answers_attributes = {"0" => {:content => "abcde", :question_id => question.id}}
        resp.create_response({:answers_attributes => answers_attributes}).should be_false
      end
    end

    it "updates the response_id for its answers' records" do
      record = FactoryGirl.create :record, :response_id => nil
      answers_attrs = {'0' => {:content => 'AnswerFoo', :question_id => question.id, :record_id => record.id}}
      resp = FactoryGirl.build(:response, :survey_id => survey.id, :user_id => 50, :organization_id => 42)
      resp.create_response(:answers_attributes => answers_attrs)
      record.reload.response_id.should_not be_nil
      record.reload.response_id.should == resp.id
    end
  end

  context "when updating a valid response from params" do
    let(:response) { FactoryGirl.create(:response) }

    it "should return nil if no params are passed in" do
      response.update_response(nil).should be_nil
    end

    it "doesn't change the response status if there isn't a param for it" do
      response = FactoryGirl.create(:response, :incomplete)
      response.update_response(:comment => "foo")
      response.reload.should be_incomplete
    end

    context "return values" do
      it "returns true when the update is successful" do
        response = FactoryGirl.create(:response, :incomplete)
        response.update_response(:comment => "foo").should be_true
      end

      it "returns false when the update is unsuccessful" do
        response = FactoryGirl.create(:response, :complete)
        response.update_response(:comment => "foo").should be_true
        mandatory_question = FactoryGirl.create(:single_line_question, :mandatory, :finalized)
        answers_attributes = {"0" => {:question_id => mandatory_question.id, :content => ""}}
        response.update_response(:answers_attributes => answers_attributes).should be_false
      end
    end

    context "when the status is changed from incomplete to complete" do
      it "doesn't change the response status if the answers are invalid" do
        response = FactoryGirl.create(:response, :incomplete)
        mandatory_question = FactoryGirl.create(:single_line_question, :mandatory, :finalized)
        answers_attributes = {"0" => {:question_id => mandatory_question.id, :content => ""}}
        response.update_response(:status => Response::Status::COMPLETE, :answers_attributes => answers_attributes)
        response.reload.should be_incomplete
      end

      it "changes the response status if the answers are valid" do
        response = FactoryGirl.create(:response, :incomplete)
        question = FactoryGirl.create(:single_line_question, :mandatory, :finalized)
        answers_attributes = {"0" => {:question_id => question.id, :content => "Foo"}}
        response.update_response(:status => Response::Status::COMPLETE, :answers_attributes => answers_attributes)
        response.reload.should be_complete
      end

      it "runs the mandatory validations" do
        response = FactoryGirl.create(:response, :incomplete)
        mandatory_question = FactoryGirl.create(:single_line_question, :mandatory, :finalized,)
        answer = FactoryGirl.create(:answer, :question => mandatory_question, :content => "foo", :response => response)
        response.reload
        answers_attributes = {"0" => {:question_id => mandatory_question.id, :content => "", :id => answer.id}}
        response.update_response(:status => Response::Status::COMPLETE, :answers_attributes => answers_attributes)
        answer.reload.content.should == "foo"
      end
    end


    it "updates the response's answers" do
      response = FactoryGirl.create(:response, :incomplete)
      question = FactoryGirl.create(:single_line_question, :finalized)
      answers_attributes = {"0" => {:question_id => question.id, :content => "Foo"}}
      response.update_response(:status => Response::Status::COMPLETE, :answers_attributes => answers_attributes)
      response.reload.answers[0].content.should == "Foo"
    end

    it "updates the response" do
      response = FactoryGirl.create(:response, :incomplete)
      response.update_response(:comment => "foo")
      response.reload.comment.should == "foo"
    end
  end

  context "when updating a response in a transaction" do
    let(:response) { FactoryGirl.create(:response) }

    context "return values" do
      it "should return nil if no params are passed in" do
        response.update_response_in_transaction(nil) {
        }.should be_nil
      end

      it 'should return nil if no block is passed in' do
        response.update_response_in_transaction({}) {
        }.should be_nil
      end

      it "should return true if the update is successful" do
        response.update_response_in_transaction({:comment => "foo"}) {
        }.should be_true
      end

      it "should return false if the update is successful" do
        question = FactoryGirl.create(:single_line_question, :finalized, :max_length => 2)
        answers_attributes = {"0" => {:question_id => question.id, :content => "abcde"}}
        response.update_response_in_transaction(:answers_attributes => answers_attributes) {
        }.should be_false
      end
    end

    it "updates the response's answers" do
      response = FactoryGirl.create(:response, :incomplete)
      question = FactoryGirl.create(:single_line_question, :finalized)
      answers_attributes = {"0" => {:question_id => question.id, :content => "Foo"}}
      response.update_response_in_transaction(:answers_attributes => answers_attributes) {}
      response.reload.answers[0].content.should == "Foo"
    end

    it "updates the response" do
      response = FactoryGirl.create(:response, :incomplete)
      response.update_response_in_transaction(:comment => "foo") {}
      response.reload.comment.should == "foo"
    end

    it "executes the block and the update in a transaction" do
      question = FactoryGirl.create(:single_line_question, :finalized, :max_length => 2)
      answers_attributes = {"0" => {:question_id => question.id, :content => "abcde"}}
      response.update_response_in_transaction(:answers_attributes => answers_attributes) do
        response.update_attribute(:comment, "foo")
      end
      response.reload.comment.should_not == "foo"
    end

    it "executes the contents of the block" do
      block = lambda { |params|}
      response_params = {:comment => "foo"}
      block.should_receive(:call).with(response_params)
      response.update_response_in_transaction(response_params, &block)
    end
  end

  context "when updating a valid response from params and resolving conflicts" do
    let(:response) { FactoryGirl.create(:response) }

    it "should return nil if no params are passed in" do
      response.update_response_with_conflict_resolution(nil).should be_nil
    end

    it "doesn't change the response status if there isn't a param for it" do
      response = FactoryGirl.create(:response, :incomplete)
      response.update_response_with_conflict_resolution(:comment => "foo")
      response.reload.should be_incomplete
    end

    context "return values" do
      it "returns true when the update is successful" do
        response = FactoryGirl.create(:response, :incomplete)
        response.update_response_with_conflict_resolution(:comment => "foo").should be_true
      end

      it "returns false when the update is unsuccessful" do
        response = FactoryGirl.create(:response, :complete)
        response.update_response_with_conflict_resolution(:comment => "foo").should be_true
        mandatory_question = FactoryGirl.create(:single_line_question, :mandatory, :finalized)
        answers_attributes = {"0" => {:question_id => mandatory_question.id, :content => ""}}
        response.update_response_with_conflict_resolution(:answers_attributes => answers_attributes).should be_false
      end
    end

    context "when the status is changed from incomplete to complete" do
      it "doesn't change the response status if the answers are invalid" do
        response = Timecop.freeze(5.days.ago) { FactoryGirl.create(:response, :incomplete) }
        mandatory_question = FactoryGirl.create(:single_line_question, :mandatory, :finalized)
        answers_attributes = {"0" => {:question_id => mandatory_question.id, :content => ""}}
        response.update_response_with_conflict_resolution(:status => Response::Status::COMPLETE, :updated_at => Time.now.to_s, :answers_attributes => answers_attributes)
        response.reload.should be_incomplete
      end

      it "changes the response status if the answers are valid" do
        response = Timecop.freeze(5.days.ago) { FactoryGirl.create(:response, :incomplete) }
        question = FactoryGirl.create(:single_line_question, :mandatory, :finalized)
        answers_attributes = {"0" => {:question_id => question.id, :content => "Foo"}}
        response.update_response_with_conflict_resolution(:status => Response::Status::COMPLETE, :updated_at => Time.now.to_s, :answers_attributes => answers_attributes)
        response.reload.should be_complete
      end

      it "runs the mandatory validations" do
        response = Timecop.freeze(5.days.ago) { FactoryGirl.create(:response, :incomplete) }
        mandatory_question = FactoryGirl.create(:single_line_question, :mandatory, :finalized)
        answer = FactoryGirl.create(:answer, :question => mandatory_question, :content => "foo", :response => response)
        response.reload
        answers_attributes = {"0" => {:question_id => mandatory_question.id, :updated_at => Time.now.to_s, :content => "", :id => answer.id}}
        response.update_response_with_conflict_resolution(:status => Response::Status::COMPLETE, :updated_at => Time.now.to_s, :answers_attributes => answers_attributes)
        answer.reload.content.should == "foo"
      end
    end

    context "when resolving conflicts" do
      it "should keep the passed in status if it is newer" do
        response = Timecop.freeze(5.days.ago) { FactoryGirl.create(:response, :incomplete) }
        response.update_response_with_conflict_resolution(:status => "complete", :updated_at => Time.now.to_s)
        response.reload.should be_complete
      end

      it 'should keep the existing status if it is newer than the passed in status' do
        response = Timecop.freeze(3.days.ago) { FactoryGirl.create(:response, :incomplete) }
        response.update_response_with_conflict_resolution(:status => "complete", :updated_at => 5.days.ago.to_s)
        response.reload.should be_incomplete
      end

      it "should keep the answer content that is newer" do
        response = Timecop.freeze(3.days.ago) { FactoryGirl.create(:response, :incomplete) }
        question = FactoryGirl.create(:single_line_question, :finalized)
        answer = Timecop.freeze(3.days.ago) { FactoryGirl.create(:answer, :question => question, :content => "foo", :response => response) }
        answers_attributes = {"0" => {:content => "bar", :updated_at => Time.now.to_s, :id => answer.id}}
        response.reload.update_response_with_conflict_resolution(:answers_attributes => answers_attributes)
        answer.reload.content.should == "bar"
      end

      it "shouldn't keep the answer content that is older" do
        response = Timecop.freeze(6.days.ago) { FactoryGirl.create(:response, :incomplete) }
        question = FactoryGirl.create(:single_line_question, :finalized)
        answer = Timecop.freeze(3.days.ago) { FactoryGirl.create(:answer, :question => question, :content => "foo", :response => response) }
        answers_attributes = {"0" => {:content => "bar", :updated_at => 5.days.ago.to_s, :id => answer.id}}
        response.reload.update_response_with_conflict_resolution(:answers_attributes => answers_attributes)
        answer.reload.content.should == "foo"
      end
    end

    it "updates the response's answers" do
      response = FactoryGirl.create(:response, :incomplete)
      question = FactoryGirl.create(:single_line_question, :finalized)
      answers_attributes = {"0" => {:question_id => question.id, :content => "Foo"}}
      response.update_response_with_conflict_resolution(:status => Response::Status::COMPLETE, :answers_attributes => answers_attributes)
      response.reload.answers[0].content.should == "Foo"
    end

    it "updates the response" do
      response = FactoryGirl.create(:response, :incomplete)
      response.update_response_with_conflict_resolution(:comment => "foo")
      response.reload.comment.should == "foo"
    end
  end

  context "#set" do
    it "sets the survey_id, user_id, organization_id and session_token" do
      survey = FactoryGirl.create(:survey)
      response = FactoryGirl.build(:response)
      response.set(survey.id, 5, 6, "foo")
      response.survey_id.should == survey.id
      response.user_id.should == 5
      response.organization_id.should == 6
      response.session_token.should == "foo"
    end
  end

  it "gets the questions that it contains answers for" do
    survey = FactoryGirl.create(:survey)
    response = FactoryGirl.build(:response, :survey_id => survey.id)
    response.questions.should == survey.questions
  end

  it "gets the public status of its survey" do
    survey = FactoryGirl.create(:survey, :public => true)
    response = FactoryGirl.build(:response, :survey_id => survey.id)
    response.survey_public?.should be_true
  end

  context "when updating answers" do
    it "selects only the new answers to update" do
      survey = FactoryGirl.create(:survey)
      response = FactoryGirl.create(:response, :survey => survey)
      question_1 = FactoryGirl.create(:question, :finalized, :survey_id => survey.id)
      question_2 = FactoryGirl.create(:question, :finalized, :survey_id => survey.id)
      answer_1 = FactoryGirl.create(:answer, :question_id => question_1.id, :updated_at => Time.now, :content => "older", :response_id => response.id)
      answer_2 = FactoryGirl.create(:answer, :question_id => question_2.id, :updated_at => 5.hours.from_now, :content => "newer", :response_id => response.id)
      answers_attributes = {'0' => {:question_id => question_1.id, :updated_at => 5.hours.from_now.to_s, :id => answer_1.id, :content => "newer"},
                            '1' => {:question_id => question_2.id, :updated_at => Time.now.to_s, :id => answer_2.id, :content => "older"}}
      selected_answers = response.select_new_answers(answers_attributes)
      selected_answers.keys.should == ['0']
    end
  end

  context "#to_json_with_answers_and_choices" do
    it "renders the answers" do
      response = (FactoryGirl.create :response_with_answers).reload
      response_json = JSON.parse(response.to_json_with_answers_and_choices)
      response_json.should have_key('answers')
      response_json['answers'].size.should == response.answers.size
    end

    it "renders the answers' image as base64 as well" do
      response = FactoryGirl.create(:response)
      photo_answer = FactoryGirl.create(:answer_with_image, :response => response)
      response.reload
      response_json = JSON.parse(response.to_json_with_answers_and_choices)
      response_json['answers'][0].should have_key('photo_in_base64')
      response_json['answers'][0]['photo_in_base64'].should == photo_answer.photo_in_base64
    end

    it "renders the answers' choices if any" do
      response = (FactoryGirl.create :response).reload
      response.answers << FactoryGirl.create(:answer_with_choices)
      response_json = JSON.parse(response.to_json_with_answers_and_choices)
      response_json['answers'][0].should have_key('choices')
      response_json['answers'][0]['choices'].size.should == response.answers[0].choices.size
    end
  end

  context 'when calculating the page size' do
    before(:each) { stub_const('Response::MAX_PAGE_SIZE', 50) }

    it "allows the passed in value if it is below MAX_PAGE_SIZE" do
      Response.page_size(10).should == 10
    end

    it "doesn't allow the passed in value if it is above MAX_PAGE_SIZE" do
      Response.page_size(51).should == 50
    end

    it "returns the MAX_PAGE_SIZE if nothing is passed in" do
      Response.page_size.should == 50
    end
  end

  context "when reloading a single attribute" do
    it 'reloads that attribute' do
      response = FactoryGirl.create(:response, :comment => "foo")
      response.comment = "xyz"
      response.reload_attribute(:comment)
      response.comment.should == "foo"
    end

    it "doesn't reload any other attribute" do
      response = FactoryGirl.create(:response, :complete, :comment => "foo")
      response.comment = "xyz"
      response.reload_attribute(:status)
      response.comment.should == "xyz"
    end
  end

  context "when creating records for each multi record category" do
    it "creates records" do
      survey = FactoryGirl.create(:survey)
      multi_record_category = FactoryGirl.create(:multi_record_category, :survey => survey)
      response = FactoryGirl.create(:response, :survey => survey)
      expect { response.create_record_for_each_multi_record_category }.to change { multi_record_category.records.count }.from(0).to(1)
    end

    it "creates records for each multi record category" do
      survey = FactoryGirl.create(:survey)
      first_multi_record_category = FactoryGirl.create(:multi_record_category, :survey => survey)
      second_multi_record_category = FactoryGirl.create(:multi_record_category, :survey => survey)
      response = FactoryGirl.create(:response, :survey => survey)
      response.create_record_for_each_multi_record_category
      response.records.map(&:category_id).should =~ [first_multi_record_category.id, second_multi_record_category.id]
    end

    it "creates records under the current response" do
      survey = FactoryGirl.create(:survey)
      multi_record_category = FactoryGirl.create(:multi_record_category, :survey => survey)
      response = FactoryGirl.create(:response, :survey => survey)
      response.create_record_for_each_multi_record_category
      multi_record_category.records.first.response_id.should == response.id
    end
  end
end

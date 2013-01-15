describe ResponseDecorator do
  it "returns the question_number for the given question" do
    resp = FactoryGirl.create(:response)
    survey = FactoryGirl.create(:survey)
    FactoryGirl.create(:question, :survey => survey, :order_number => 1)
    question = FactoryGirl.create(:question, :survey => survey, :order_number => 3)
    ResponseDecorator.question_number(question).should == "2"
  end

  it "returns the correct question_number for child questions" do
    resp = FactoryGirl.create(:response)
    survey = FactoryGirl.create(:survey)
    FactoryGirl.create(:question, :survey => survey, :order_number => 1)
    parent_question = FactoryGirl.create(:question_with_options, :survey => survey, :order_number => 3)
    parent_question = RadioQuestion.find(parent_question.id)
    FactoryGirl.create(:question, :survey => survey, :parent => parent_question.options.first, :order_number => 1)
    question = FactoryGirl.create(:question, :survey => survey, :parent => parent_question.options.first, :order_number => 3)
    ResponseDecorator.question_number(question).should == '2.2'
  end

  it "returns the correct question_number for sub questions of multi choice questions" do
    resp = FactoryGirl.create(:response)
    survey = FactoryGirl.create(:survey)

    question = MultiChoiceQuestion.create({content: "Untitled question", survey_id: survey.id, order_number: 0})
    parent_option = Option.create(content: "Option", order_number: 0)
    question.options << parent_option
    question.options << Option.create(content: "Option", order_number: 1)
    question.options << Option.create(content: "Option", order_number: 2)
    sub_question = SingleLineQuestion.create({content: "Untitled question", survey_id: survey.id, order_number: 0})
    parent_option.questions << sub_question

    ResponseDecorator.question_number(sub_question).should == '1A.1'
  end
end

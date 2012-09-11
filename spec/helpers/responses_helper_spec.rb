describe ResponsesHelper do
  it "should return an appropriate hint based on numeric question range" do
    numeric_question_hint(1, 3).should include("1", "3")
    numeric_question_hint(1, nil).should include("1")
    numeric_question_hint(nil, 3).should include("3")
    numeric_question_hint(nil, nil).should be_nil	
  end
end
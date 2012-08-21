describe "Survey", ->
  beforeEach ->
    loadFixtures "survey"
    new SurveyApp.Survey($(".settings_pane"), $(".form_pane"))

  it "adds a question to the questions div on clicking", ->
    $(".add_question_field").click()
    expect($("#questions")).toHaveText(/Question 0/)

  it "keeps a count of the number of questions added", ->
    $(".add_question_field").click()
    $(".add_question_field").click()
    expect($("#questions")).toHaveText(/Question 1/)
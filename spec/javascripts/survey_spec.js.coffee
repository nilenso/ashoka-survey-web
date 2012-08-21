describe "SurveyBuilder", ->
  beforeEach ->
    loadFixtures "survey"
    new SurveyApp.SurveyBuilder($(".sidebar"), $(".form_pane"))

  it "adds a question to the questions div on clicking", ->
    $(".add_question_field").click()
    expect($("#questions")).toHaveText(/Question 0/)

  it "keeps a count of the number of questions added", ->
    $(".add_question_field").click()
    $(".add_question_field").click()
    expect($("#questions")).toHaveText(/Question 1/)

  describe "when switching tabs in the sidebar", ->
    it "switches to the clicked tab", ->
      tab = $('.tabs').find('li').first()
      tab.click()
      target = $(tab.data('tab-target'))
      expect(target).not.toBeHidden()

    it "hides all tabs except the clicked one", ->
      tab = $('.tabs').find('li').first()
      tab.click()
      other_tab = $('.tabs').find('li').last()
      other_target = $(other_tab.data('tab-target'))
      expect(other_target).toBeHidden()
    
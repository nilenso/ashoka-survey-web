describe "SurveyElement", ->
  beforeEach ->
    loadFixtures 'survey_element'
    @actual = $("#actual")
    @dummy = $("#dummy")
    @sidebar_div = $(".sidebar")
    @survey_element = new SurveyApp.SurveyElement(@actual, @dummy, @sidebar_div)
    
  it "binds the keyup event for all inputs in the actual fieldset", ->
    expect($("#actual").find('input')).toHandleWith('keyup', @survey_element.mirrorKeyup)

  it "binds the change event for all inputs in the actual fieldset", ->
    expect($("#actual").find('input')).toHandleWith('change', @survey_element.mirrorKeyup)  

  it "fills in the dummy input with the value in the actual input", ->
    @actual.find('input').val("some text")
    @actual.find('input').keyup()
    expect(@dummy.find('input')).toHaveValue("some text")

  it "fills in the matching dummy input only", ->
    @actual.find('input[name=1]').val("some text")
    @actual.find('input[name=1]').keyup()
    expect(@dummy.find('input[name=1]')).toHaveValue("some text")
    expect(@dummy.find('input[name=2]')).not.toHaveValue("some text")

  it "fills in the matching dummy textarea only", ->
    @actual.find('textarea[name=1]').val("some text")
    @actual.find('textarea[name=1]').keyup()
    expect(@dummy.find('textarea[name=1]')).toHaveValue("some text")
    expect(@dummy.find('textarea[name=2]')).not.toHaveValue("some text")

  describe "when clicking on corresponding dummy", ->
    it "shows only the actual fieldset in the settings pane", ->
      @dummy.click()
      expect(@sidebar_div.find("#survey_details")).toBeHidden()
      expect(@actual).toBeVisible()
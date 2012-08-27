describe "SurveyElement", ->
  beforeEach ->
    loadFixtures 'survey_element'
    @actual = $("#actual")
    @dummy = $("#dummy")
    @sidebar_div = $(".sidebar")
    @dummy_div = $("#dummy_form_display")
    @survey_element = new SurveyApp.SurveyElement(@actual, @dummy)
    
  it "binds the keyup event for all inputs in the actual fieldset", ->
    expect($("#actual").find('input')).toHandleWith('keyup', @survey_element.mirror)

  it "binds the change event for all inputs in the actual fieldset", ->
    expect($("#actual").find('input')).toHandleWith('change', @survey_element.mirror)

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

  describe "when showing itself", ->
    it "shows the actual fieldset in the settings pane", ->
      @survey_element.show()
      expect(@actual).toBeVisible()

    it "adds a highlight to the dummy fieldset", ->
      @survey_element.show()
      expect(@dummy).toHaveClass('active')

  describe "when hiding itself", ->
    beforeEach ->
      @survey_element.show()
      
    it "hides the actual fieldset in the settings pane", ->
      @survey_element.hide()
      expect(@actual).toBeHidden()

    it "removes the highlight in the dummy fieldset", ->      
      @survey_element.hide()
      expect(@dummy).not.toHaveClass('active')
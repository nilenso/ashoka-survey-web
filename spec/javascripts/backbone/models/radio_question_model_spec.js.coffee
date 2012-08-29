describe "SurveyBuilder.Models.RadioQuestionModel", ->
  it "can be instantiated", ->
    model = new SurveyBuilder.Models.RadioQuestionModel
    expect(model).not.toBeNull

  describe "when setting defaults", ->
    it "sets type to RadioQuestion", ->
      model = new SurveyBuilder.Models.RadioQuestionModel
      expect(model.get('type')).toEqual('RadioQuestion')

    it "sets content to Untitled question", ->
      model = new SurveyBuilder.Models.RadioQuestionModel
      expect(model.get('content')).toContain('Untitled')

  it "should make the correct server request when it is empty", ->
    model = new SurveyBuilder.Models.RadioQuestionModel
    spy = sinon.spy(jQuery, "ajax")
    model.save()
    expect(spy.getCall(0).args[0].url).toContain "/questions"
    jQuery.ajax.restore()




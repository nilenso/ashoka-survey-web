describe "SurveyBuilder.Models.SingleLineQuestionModel", ->
  it "can be instantiated", ->
    model = new SurveyBuilder.Models.SingleLineQuestionModel
    expect(model).not.toBeNull

  describe "when setting defaults", ->
    it "sets type to SingleLineQuestion", ->
      model = new SurveyBuilder.Models.SingleLineQuestionModel
      expect(model.get('type')).toEqual('SingleLineQuestion')

    it "sets content to Untitled question", ->
      model = new SurveyBuilder.Models.SingleLineQuestionModel
      expect(model.get('content')).toContain('Untitled')

    it "sets mandatory to false", ->
      model = new SurveyBuilder.Models.SingleLineQuestionModel
      expect(model.get('mandatory')).toEqual(false)

  it "should make the correct server request", ->
    model = new SurveyBuilder.Models.SingleLineQuestionModel
    spy = sinon.spy(jQuery, "ajax")
    model.save()
    expect(spy.getCall(0).args[0].url).toContain "/api/questions"
    jQuery.ajax.restore()

  describe "after saving", ->
    it "knows if a save failed with errors", ->
      model = new SurveyBuilder.Models.SingleLineQuestionModel()
      model.error_callback({}, {responseText: JSON.stringify(['xyz'])})
      expect(model.has_errors()).toBeTruthy()

    it "can return the error messages as an array", ->
      model = new SurveyBuilder.Models.SingleLineQuestionModel()
      model.error_callback({}, {responseText: JSON.stringify(['xyz'])})
      expect(model.errors).toEqual(jasmine.any(Array))
      expect(model.errors).toContain('xyz')

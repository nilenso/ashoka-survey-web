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

    it "sets mandatory to Untitled question", ->
      model = new SurveyBuilder.Models.RadioQuestionModel
      expect(model.get('mandatory')).toEqual(false)

    it "sets image to Untitled question", ->
      model = new SurveyBuilder.Models.RadioQuestionModel
      expect(model.get('image')).toBeNull

  it "should make the correct server request", ->
    model = new SurveyBuilder.Models.RadioQuestionModel
    spy = sinon.spy(jQuery, "ajax")
    model.save()
    expect(spy.getCall(0).args[0].url).toContain "/api/questions"
    jQuery.ajax.restore()

  it "contains options", ->
    model = new SurveyBuilder.Models.RadioQuestionModel
    expect(model.get('options')).toEqual(jasmine.any(SurveyBuilder.Collections.OptionCollection))

  it "can seed 3 placeholder options within it", ->
    model = new SurveyBuilder.Models.RadioQuestionModel
    model.seed()
    expect(model.get('options').length).toEqual(3)

  describe "after saving", ->
    it "knows if a save failed with errors", ->
      model = new SurveyBuilder.Models.RadioQuestionModel()
      model.error_callback({}, {responseText: JSON.stringify(['xyz'])})
      expect(model.has_errors()).toBeTruthy()

    it "can return the error messages as an array", ->
      model = new SurveyBuilder.Models.RadioQuestionModel()
      model.error_callback({}, {responseText: JSON.stringify(['xyz'])})
      expect(model.errors).toEqual(jasmine.any(Array))
      expect(model.errors).toContain('xyz')
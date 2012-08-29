describe "SurveyBuilder.Models.OptionModel", ->
  it "can be instantiated", ->
    model = new SurveyBuilder.Models.OptionModel
    expect(model).not.toBeNull

  describe "when using defaults", ->
    it "sets the content to untitled", ->
      model = new SurveyBuilder.Models.OptionModel
      expect(model.get('content')).toContain('untitled')   

  it "should make the correct server request when it is empty", ->
    model = new SurveyBuilder.Models.OptionModel()
    spy = sinon.spy(jQuery, "ajax")
    model.save()
    expect(spy.getCall(0).args[0].url).toContain '/api/options'
    jQuery.ajax.restore()   

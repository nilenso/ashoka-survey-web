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

  describe "SurveyBuilder.Collections.OptionCollection", ->
    it "can be instantiated", ->
      collection = new SurveyBuilder.Collections.OptionCollection
      expect(collection).not.toBeNull

    it "is a collection of OptionModels", ->
      collection = new SurveyBuilder.Collections.OptionCollection
      collection.add({content: 'Hello'})
      expect(collection.models[0]).toEqual(jasmine.any((SurveyBuilder.Models.OptionModel)))

    it "should make the correct server request when creating a new element", ->
      collection = new SurveyBuilder.Collections.OptionCollection
      spy = sinon.spy(jQuery, "ajax")
      collection.create({content: 'Hello'})
      expect(spy.getCall(0).args[0].url).toContain '/api/options'
      jQuery.ajax.restore()   

  describe "when saving", ->
    it "knows if a save failed with errors", ->
      model = new SurveyBuilder.Models.OptionModel()
      model.error_callback({}, {responseText: JSON.stringify(['xyz'])})
      expect(model.has_errors()).toBeTruthy()
describe "SurveyBuilder.Models.OptionModel", ->
  it "can be instantiated", ->
    model = new SurveyBuilder.Models.OptionModel
    expect(model).not.toBeNull

  describe "when using defaults", ->
    it "sets the content to untitled", ->
      model = new SurveyBuilder.Models.OptionModel
      expect(model.get('content')).toContain('untitled')      

describe "SurveyBuilder.Collections.OptionsCollection", ->
  it "can be instantiated", ->
    collection = new SurveyBuilder.Collections.OptionsCollection
    expect(collection).not.toBeNull

  it "is tied to the OptionModel", ->
    model = new SurveyBuilder.Models.OptionModel
    collection = new SurveyBuilder.Collections.OptionsCollection
    collection.add(model)
    setTimeout(2000, ->
      expect(collection.get(model.id)).toEqual(jasmine.any(SurveyBuilder.Collections.OptionsCollection))
    )

  it "adds 3 blank OptionModels when it is initialized", ->
    collection = new SurveyBuilder.Collections.OptionsCollection 
    expect(collection.size()).toEqual(3)
    collection.each (elem) ->
      expect(elem).toEqual(jasmine.any(SurveyBuilder.Models.OptionModel))

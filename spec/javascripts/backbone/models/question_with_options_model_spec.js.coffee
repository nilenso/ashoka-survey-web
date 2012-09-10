describe "SurveyBuilder.Models.QuestionWithOptionsModel", ->
  it "can be instantiated", ->
    model = new SurveyBuilder.Models.QuestionWithOptionsModel
    expect(model).not.toBeNull

  it "contains options", ->
    model = new SurveyBuilder.Models.QuestionWithOptionsModel
    expect(model.get('options')).toEqual(jasmine.any(SurveyBuilder.Collections.OptionCollection))

  it "can seed 3 placeholder options within it", ->
    model = new SurveyBuilder.Models.QuestionWithOptionsModel
    model.seed()
    expect(model.get('options').length).toEqual(3)

  it "creates a new option in its options collection", ->
    model = new SurveyBuilder.Models.QuestionWithOptionsModel()
    model.create_new_option()
    expect(model.get('options').length).toEqual(1)
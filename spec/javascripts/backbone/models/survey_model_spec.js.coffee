describe "SurveyBuilder.Models.SurveyModel", ->
  describe "when instantiating", ->
    it "can be instantiated", ->
      survey_model = new SurveyBuilder.Models.SurveyModel
      expect(survey_model).not.toBeNull

    it "should have a survey_id", ->
      survey_id = "123"
      survey_model = new SurveyBuilder.Models.SurveyModel(survey_id)
      expect(survey_model.survey_id).not.toBeNull()

    it "instantiates a empty array of question models ", ->
      survey_id = "321"
      survey_model = new SurveyBuilder.Models.SurveyModel(survey_id)
      expect(survey_model.question_models).toBeDefined()

  describe "when adding a question", ->
    it "creates a new question model and adds it to the list of question models", ->
      survey_id = "321"
      survey_model = new SurveyBuilder.Models.SurveyModel(survey_id)
      question_model = survey_model.add_new_question_model()
      expect(survey_model.question_models).toContain(question_model)

  it "saves all the questions present in the list of question models", ->
    survey_id = "321"
    survey_model = new SurveyBuilder.Models.SurveyModel(survey_id)
    question_model = survey_model.add_new_question_model()
    spyOn(question_model, 'save_with_options')
    survey_model.save_all_questions()
    expect(question_model.save_with_options).toHaveBeenCalled()

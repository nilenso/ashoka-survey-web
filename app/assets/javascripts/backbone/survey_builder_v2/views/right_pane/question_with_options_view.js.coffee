class SurveyBuilderV2.Views.RightPane.QuestionWithOptionsView extends SurveyBuilderV2.Views.RightPane.QuestionView
  templatePath: =>
    "v2_survey_builder/surveys/right_pane/question_with_options"

  saveQuestion: =>
    @savingIndicator.show()
    @model.save({}, success: @handleUpdateSuccess, error: @handleUpdateError)
    _.delay(@saveOptions, 1000);

  saveOptions: =>
    @model.get('options').each (option) =>
      option.save(question_id: @model.get('id'))

  addOptionsInBulk: (event) =>
    csv = $(event.target).val()
    parsed_csv = $.csv.toArray(csv)

    for option in parsed_csv
      @model.createNewOption(option.trim()) if option && option.length > 0

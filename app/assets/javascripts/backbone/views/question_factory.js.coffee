class SurveyBuilder.Views.QuestionFactory extends Backbone.View
  @Types = {
    SINGLE_LINE : 'SingleLineQuestion',
    MULTILINE : 'MultilineQuestion',
    NUMERIC :'NumericQuestion',
    DATE : 'DateQuestion',
    RADIO : 'RadioQuestion',
    MULTI_CHOICE : 'MultiChoiceQuestion',
    DROP_DOWN : 'DropDownQuestion',
    PHOTO : 'PhotoQuestion'
    RATING : 'RatingQuestion',
    MULTI_RECORD : 'MultiRecordCategory',
    CATEGORY : null
  }

  @is_with_options: (type) =>
    type in [@Types.RADIO, @Types.MULTI_CHOICE, @Types.DROP_DOWN]

  @dummy_view_for: (type, model) =>
    type = null unless type
    switch type
      when @Types.SINGLE_LINE
        template = $('#dummy_single_line_question_template').html()
        return new SurveyBuilder.Views.Dummies.QuestionView(model, template)
      when @Types.MULTILINE
        template = $('#dummy_multiline_question_template').html()
        return new SurveyBuilder.Views.Dummies.QuestionView(model, template)
      when @Types.NUMERIC
        template = $('#dummy_numeric_question_template').html()
        return new SurveyBuilder.Views.Dummies.QuestionView(model, template)
      when @Types.DATE
        template = $('#dummy_date_question_template').html()
        return new SurveyBuilder.Views.Dummies.QuestionView(model, template)
      when @Types.RADIO
        template = $('#dummy_radio_question_template').html()
        return new SurveyBuilder.Views.Dummies.QuestionWithOptionsView(model, template)
      when @Types.MULTI_CHOICE
        template = $('#dummy_multi_choice_question_template').html()
        return new SurveyBuilder.Views.Dummies.QuestionWithOptionsView(model, template)
      when @Types.DROP_DOWN
        template = $('#dummy_drop_down_question_template').html()
        return new SurveyBuilder.Views.Dummies.QuestionWithOptionsView(model, template)
      when @Types.PHOTO
        template = $('#dummy_photo_question_template').html()
        return new SurveyBuilder.Views.Dummies.QuestionView(model, template)
      when @Types.RATING
        template = $('#dummy_rating_question_template').html()
        return new SurveyBuilder.Views.Dummies.QuestionView(model, template)
      when 'MultiRecordQuestion'
        template = $('#dummy_multi_record_question_template').html()
        return new SurveyBuilder.Views.Dummies.MultiRecordQuestionView(model)
      when @Types.CATEGORY
        if model instanceof SurveyBuilder.Models.CategoryModel
          return new SurveyBuilder.Views.Dummies.CategoryView(model)
      when @Types.MULTI_RECORD
        return new SurveyBuilder.Views.Dummies.CategoryView(model)

  @settings_view_for: (type, model) =>
    type = null unless type
    switch type
      when @Types.SINGLE_LINE
        template = $('#single_line_question_template').html()
        return new SurveyBuilder.Views.Questions.QuestionView(model, template)
      when @Types.MULTILINE
        template = $('#multiline_question_template').html()
        return new SurveyBuilder.Views.Questions.QuestionView(model, template)
      when @Types.NUMERIC
        template = $('#numeric_question_template').html()
        return new SurveyBuilder.Views.Questions.QuestionView(model, template)
      when @Types.DATE
        template = $('#date_question_template').html()
        return new SurveyBuilder.Views.Questions.QuestionView(model, template)
      when @Types.RADIO
        template = $('#radio_question_template').html()
        return new SurveyBuilder.Views.Questions.QuestionWithOptionsView(model, template)
      when @Types.MULTI_CHOICE
        template = $('#multi_choice_question_template').html()
        return new SurveyBuilder.Views.Questions.QuestionWithOptionsView(model, template)
      when @Types.DROP_DOWN
        template = $('#drop_down_question_template').html()
        return new SurveyBuilder.Views.Questions.QuestionWithOptionsView(model, template)
      when @Types.PHOTO
        template = $('#photo_question_template').html()
        return new SurveyBuilder.Views.Questions.QuestionView(model, template)
      when @Types.RATING
        template = $('#rating_question_template').html()
        return new SurveyBuilder.Views.Questions.QuestionView(model, template)
      when 'MultiRecordQuestion'
        template = $('#multi_record_question_template').html()
        return new SurveyBuilder.Views.Questions.MultiRecordQuestionView(model)
      when @Types.CATEGORY
        if model instanceof SurveyBuilder.Models.CategoryModel
          return new SurveyBuilder.Views.Questions.CategoryView(model)
      when @Types.MULTI_RECORD
        return new SurveyBuilder.Views.Questions.CategoryView(model)

  @model_for: (model) =>
    model.type = null unless model.type
    if (@is_with_options(model.type))
      new SurveyBuilder.Models.QuestionWithOptionsModel(model)
    else if  model.type == @Types.CATEGORY
      new SurveyBuilder.Models.CategoryModel(model)
    else if  model.type == @Types.MULTI_RECORD
      new SurveyBuilder.Models.CategoryModel(model)
    else
      new SurveyBuilder.Models.QuestionModel(model)

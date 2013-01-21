class SurveyBuilder.Views.QuestionFactory extends Backbone.View
  @dummy_view_for: (type, model) =>
    switch type
      when 'SingleLineQuestion'
        template = $('#dummy_single_line_question_template').html()
        return new SurveyBuilder.Views.Dummies.QuestionView(model, template)
      when 'MultilineQuestion'
        template = $('#dummy_multiline_question_template').html()
        return new SurveyBuilder.Views.Dummies.QuestionView(model, template)
      when 'NumericQuestion'
        template = $('#dummy_numeric_question_template').html()
        return new SurveyBuilder.Views.Dummies.QuestionView(model, template)
      when 'DateQuestion'
        template = $('#dummy_date_question_template').html()
        return new SurveyBuilder.Views.Dummies.QuestionView(model, template)
      when 'RadioQuestion'
        template = $('#dummy_radio_question_template').html()
        return new SurveyBuilder.Views.Dummies.QuestionWithOptionsView(model, template)
      when 'MultiChoiceQuestion'
        template = $('#dummy_multi_choice_question_template').html()
        return new SurveyBuilder.Views.Dummies.QuestionWithOptionsView(model, template)
      when 'DropDownQuestion'
        template = $('#dummy_drop_down_question_template').html()
        return new SurveyBuilder.Views.Dummies.QuestionWithOptionsView(model, template)
      when 'PhotoQuestion'
        template = $('#dummy_photo_question_template').html()
        return new SurveyBuilder.Views.Dummies.QuestionView(model, template)
      when 'RatingQuestion'
        template = $('#dummy_rating_question_template').html()
        return new SurveyBuilder.Views.Dummies.QuestionView(model, template)
      when undefined
        if model instanceof SurveyBuilder.Models.CategoryModel
          return new SurveyBuilder.Views.Dummies.CategoryView(model)

  @settings_view_for: (type, model) =>
    switch type
      when 'SingleLineQuestion'
        template = $('#single_line_question_template').html()
        return new SurveyBuilder.Views.Questions.QuestionView(model, template)
      when 'MultilineQuestion'
        template = $('#multiline_question_template').html()
        return new SurveyBuilder.Views.Questions.QuestionView(model, template)
      when 'NumericQuestion'
        template = $('#numeric_question_template').html()
        return new SurveyBuilder.Views.Questions.QuestionView(model, template)
      when 'DateQuestion'
        template = $('#date_question_template').html()
        return new SurveyBuilder.Views.Questions.QuestionView(model, template)
      when 'RadioQuestion'
        template = $('#radio_question_template').html()
        return new SurveyBuilder.Views.Questions.QuestionWithOptionsView(model, template)
      when 'MultiChoiceQuestion'
        template = $('#multi_choice_question_template').html()
        return new SurveyBuilder.Views.Questions.QuestionWithOptionsView(model, template)
      when 'DropDownQuestion'
        template = $('#drop_down_question_template').html()
        return new SurveyBuilder.Views.Questions.QuestionWithOptionsView(model, template)
      when 'PhotoQuestion'
        template = $('#photo_question_template').html()
        return new SurveyBuilder.Views.Questions.QuestionView(model, template)
      when 'RatingQuestion'
        template = $('#rating_question_template').html()
        return new SurveyBuilder.Views.Questions.QuestionView(model, template)
      when undefined
        if model instanceof SurveyBuilder.Models.CategoryModel
          return new SurveyBuilder.Views.Questions.CategoryView(model)

  @model_for: (type, model) =>
    switch type
      # Refactor for three cases only
      when 'MultiChoiceQuestion'
        #TODO: Why is this a subquestion model?
        sub_question_model = new SurveyBuilder.Models.QuestionWithOptionsModel(model)
      when 'DropDownQuestion'
        sub_question_model = new SurveyBuilder.Models.QuestionWithOptionsModel(model)
      when 'RadioQuestion'
        sub_question_model = new SurveyBuilder.Models.QuestionWithOptionsModel(model)
      #TODO: undefined?
      when undefined
        sub_question_model = new SurveyBuilder.Models.CategoryModel(model)
      else
        sub_question_model = new SurveyBuilder.Models.QuestionModel(model)

class SurveyBuilderV2.Views.LeftPane.OptionView extends SurveyBuilderV2.Backbone.View
  events:
    "click .question-add-sub-question": "addSubQuestion"

  render: =>
    this.$el.append(@template(@model.attributes))
    @loadSubQuestions()
    return this

  addSubQuestion: =>
    SurveyBuilderV2.Views.QuestionCreator.render(null, el, attributes)

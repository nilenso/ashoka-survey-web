class SurveyBuilderV2.Views.RightPane.SingleLineQuestionView extends Backbone.View
  el: ".survey-panes-right-pane"

  events:
    "keyup .question-content-textarea": "updateModelContent"
    "click .question-settings input": "updateModelSettings"

  initialize: (attributes) =>
    @model = attributes.model
    @template = SMT["v2_survey_builder/surveys/right_pane/single_line_question"]

  render: =>
    this.$el.html(@template(@model.attributes))

  updateModelContent: (event) =>
    content = $(event.target).val()
    @model.set({ content: content })

  updateModelSettings: (event) =>
    key = $(event.target).attr('id')
    value = $(event.target).is(':checked')
    @model.set(key, value)
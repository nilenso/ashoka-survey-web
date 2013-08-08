class SurveyBuilderV2.Views.RightPane.SingleLineQuestionView extends SurveyBuilderV2.Backbone.View
  el: ".survey-panes-right-pane"

  events:
    "keyup .question-content-textarea": "updateModelContent"
    "click .question-settings input": "updateModelSettings"
    "click .question-update": "saveQuestion"

  initialize: (attributes) =>
    @model = attributes.model
    @template = SMT["v2_survey_builder/surveys/right_pane/single_line_question"]
    @savingIndicator = new SurveyBuilderV2.Views.SavingIndicatorView
    @model.on("change:errors", @render)

  render: =>
    this.$el.html(@template(@model.attributes))

  updateModelContent: (event) =>
    content = $(event.target).val()
    @model.set({ content: content })

  updateModelSettings: (event) =>
    key = $(event.target).attr('id')
    value = $(event.target).is(':checked')
    @model.set(key, value)

  saveQuestion: =>
    @savingIndicator.show()
    @model.save({}, success: @handleUpdateSuccess, error: @handleUpdateError)

  handleUpdateSuccess: (model, response, options) =>
    @model.unset("errors")
    @savingIndicator.hide()

  handleUpdateError: (model, response, options) =>
    @model.set(JSON.parse(response.responseText))
    @savingIndicator.error()
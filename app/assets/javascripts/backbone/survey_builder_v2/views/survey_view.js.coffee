class SurveyBuilderV2.Views.SurveyView extends SurveyBuilderV2.Backbone.View
  events:
    "click .survey-header": "toggleCollapse"
    "click .update-survey": "updateModel"
    "click .add-question": "addNewQuestion"

  initialize: (attributes) =>
    @model = new SurveyBuilderV2.Models.SurveyModel(attributes.survey)
    @model.on("change", @render)
    @nonEditableTemplate = SMT["v2_survey_builder/surveys/header"]
    @editableTemplate = SMT["v2_survey_builder/surveys/header_edit"]
    @savingIndicator = new SurveyBuilderV2.Views.SavingIndicatorView

    globalMessageBus.bind("clear_left_pane_selections", @clearLeftPaneSelection)

    questions = _(attributes.questions).map(@addQuestion)
    _(questions).first().makeActive() if questions.length > 0

  getEditableView: => this.$el.find(".survey-header-edit")
  getLeftPane: => this.$el.find(".survey-panes-left-pane")

  toggleCollapse: =>
    @getEditableView().slideToggle('slow')

  render: =>
    this.$el.find(".survey-metadata").html(@nonEditableTemplate(@model.attributes))
    this.$el.find(".survey-header-edit-information").html(@editableTemplate(@model.attributes))
    return this

  updateModel: =>
    name = @getEditableView().find("input[name=name]").val()
    description = @getEditableView().find("textarea[name=description]").val()
    @savingIndicator.show()
    @toggleCollapse()
    @model.save({ name: name, description: description },
      success: @handleUpdateSuccess, error: @handleUpdateError)

  handleUpdateSuccess: (model, response, options) =>
    @model.unset("errors")
    @savingIndicator.hide()

  handleUpdateError: (model, response, options) =>
    @savingIndicator.error()
    @model.set(JSON.parse(response.responseText))
    @toggleCollapse()

  clearLeftPaneSelection: (view) =>
    @currentlyActiveView.deselect() if @currentlyActiveView
    @currentlyActiveView = view

  addNewQuestion: (event) =>
    event.stopPropagation()

    view = @addQuestion({ survey_id: @model.get('id') })
    @getLeftPane().append(view.render().el)
    view.makeActive()

  addQuestion: (attributes) =>
    el = this.$el.find(".question[data-id=#{attributes.id}]") if attributes.id
    type = el.data("type") if attributes.type
    view = SurveyBuilderV2.Views.QuestionCreator.render(type, el, attributes)
    view

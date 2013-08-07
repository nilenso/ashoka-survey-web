class SurveyBuilderV2.Views.SurveyView extends Backbone.View
  events:
    "click .survey-header": "toggleCollapse"
    "click .update-survey": "updateModel"

  initialize: (attributes) =>
    @model = new SurveyBuilderV2.Models.SurveyModel(attributes.survey)
    @model.on("change", @render)
    @nonEditableTemplate = SMT["v2_survey_builder/surveys/header"]
    @editableTemplate = SMT["v2_survey_builder/surveys/header_edit"]
    @savingIndicator = new SurveyBuilderV2.Views.SavingIndicatorView

    _(attributes.questions).each (question) => @addQuestion(question)

  getEditableView: => this.$el.find(".survey-header-edit")

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
    @savingIndicator.hide()
    @model.unset("errors")

  handleUpdateError: (model, response, options) =>
    @savingIndicator.error()
    @model.set(JSON.parse(response.responseText))
    @toggleCollapse()

  clearLeftPaneSelection: (view) =>
    @currentlyActiveView.deselect() if @currentlyActiveView
    @currentlyActiveView = view

  addQuestion: (attributes) =>
    el = this.$el.find(".question[data-id=#{attributes.id}]")
    view = new SurveyBuilderV2.Views.LeftPane.SingleLineQuestionView({ el: el, question: attributes })
    view.on("clear_left_pane_selections", @clearLeftPaneSelection)
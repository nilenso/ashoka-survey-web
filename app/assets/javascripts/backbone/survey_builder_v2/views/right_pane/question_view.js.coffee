class SurveyBuilderV2.Views.RightPane.QuestionView extends SurveyBuilderV2.Backbone.View
  el: '.survey-panes-right-pane'

  initialize: (attributes) =>
    @model = attributes.model
    @offset = attributes.offset
    @leftPaneView = attributes.leftPaneView

    @savingIndicator = new SurveyBuilderV2.Views.SavingIndicatorView
    @model.on("change:errors", @render)

  render: =>
    this.$el.html(@template(@model.attributes))
    @setMargin()

    return this

  setMargin: =>
    headerHeight = this.$el.offset().top
    this.$el.find(".question").css('margin-top', @offset - headerHeight)

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

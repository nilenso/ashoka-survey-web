class SurveyBuilderV2.Views.AnswerTypeSwitcher
  constructor: (@source, @originaLeftView) ->

  getLeftPane: => $(".survey-panes-left-pane")

  switch: (event) =>
    option = $(event.target).val()

    if option == @source
      return
    else if option == "NumericQuestion"
      newLeftView = new SurveyBuilderV2.Views.LeftPane.NumericQuestionView({survey_id: 16})
    else if option == "SingleLineQuestion"
      newLeftView = new SurveyBuilderV2.Views.LeftPane.SingleLineQuestionView({survey_id: 16})

    @addNewQuestionView(newLeftView)

  addNewQuestionView: (newLeftView) =>
    @destroyOldQuestion()
    newLeftView.on("clear_left_pane_selections", @clearLeftPaneSelection)
    @getLeftPane().append(newLeftView.el)
    newLeftView.render()
    newLeftView.makeActive()

  destroyOldQuestion: =>
    @originaLeftView.destroyAll()

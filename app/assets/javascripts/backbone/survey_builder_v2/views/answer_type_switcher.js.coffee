class SurveyBuilderV2.Views.AnswerTypeSwitcher
  constructor: (@source, @originaLeftView) ->

  getLeftPane: => $(".survey-panes-left-pane")

  switch: (event) =>
    option = $(event.target).val()

    if option == @source
      return
    else if option == "NumericQuestion"
      newLeftView = new SurveyBuilderV2.Views.LeftPane.NumericQuestionView({survey_id: 15})
    else if option == "SingleLineQuestion"
      newLeftView = new SurveyBuilderV2.Views.LeftPane.SingleLineQuestionView({survey_id: 15})
    else if option == "MultiLineQuestion"
      newLeftView = new SurveyBuilderV2.Views.LeftPane.MultiLineQuestionView({survey_id: 15})
    else if option == "DateQuestion"
      newLeftView = new SurveyBuilderV2.Views.LeftPane.DateQuestionView({survey_id: 15})

    @addNewQuestionView(newLeftView)

  addNewQuestionView: (newLeftView) =>
    @destroyOldQuestion()
    @getLeftPane().append(newLeftView.el)
    newLeftView.render()
    newLeftView.makeActive()

  destroyOldQuestion: =>
    @originaLeftView.destroyAll()

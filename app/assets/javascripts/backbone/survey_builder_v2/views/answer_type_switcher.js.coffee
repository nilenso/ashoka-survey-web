class SurveyBuilderV2.Views.AnswerTypeSwitcher
  @switch: (source, targetEvent, originaLeftView, question) =>
    target = $(targetEvent.target).val()
    return if source == target
    originaLeftView.destroyAll()
    $('.survey-panes').append("<div class='survey-panes-right-pane'></div>") #unless $(".survey-panes-right-pane").length
    SurveyBuilderV2.Views.QuestionCreator.render(target, null, question).render()

class SurveyBuilderV2.Views.QuestionCreator
  @render: (type, el, question) =>
    if type == "NumericQuestion"
      newLeftView = new SurveyBuilderV2.Views.LeftPane.NumericQuestionView(el: el, question: question)
    else if type == "SingleLineQuestion"
      newLeftView = new SurveyBuilderV2.Views.LeftPane.SingleLineQuestionView(el: el, question: question)
    else if type == "MultilineQuestion"
      newLeftView = new SurveyBuilderV2.Views.LeftPane.MultiLineQuestionView(el: el, question: question)
    else if type == "DateQuestion"
      newLeftView = new SurveyBuilderV2.Views.LeftPane.DateQuestionView(el: el, question: question)
    else if type == "RatingQuestion"
      newLeftView = new SurveyBuilderV2.Views.LeftPane.RatingQuestionView(el: el, question: question)
    else if type == "MultiChoiceQuestion"
      newLeftView = new SurveyBuilderV2.Views.LeftPane.MultiChoiceQuestionView(el: el, question: question)
    else
      newLeftView = new SurveyBuilderV2.Views.LeftPane.SingleLineQuestionView(el: el, question: question)

    @addNewQuestionView(newLeftView)
    newLeftView

  @getLeftPane: => $(".survey-panes-left-pane")

  @addNewQuestionView: (newLeftView) =>
    @getLeftPane().append(newLeftView.el)
    newLeftView.render()
    newLeftView.makeActive()

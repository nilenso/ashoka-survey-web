class SurveyBuilderV2.Views.AnswerTypeSwitcher
  @switch: (source, targetEvent, originaLeftView, question) =>
    target = $(targetEvent.target).val()
    return if source == target
    originaLeftView.destroyAll()
    $('.survey-panes').append("<div class='survey-panes-right-pane'></div>")
    SurveyBuilderV2.Views.QuestionCreator.render(target, null, question).render()

class SurveyBuilderV2.Views.QuestionCreator
  @render: (type, el, question) =>
    newLeftView = new (SurveyBuilderV2.Views.LeftPane["#{type}View"] || SurveyBuilderV2.Views.LeftPane.SingleLineQuestionView)
      el: el
      question: question

    @addNewQuestionView(newLeftView)
    newLeftView

  @getLeftPane: => $(".survey-panes-left-pane")

  @addNewQuestionView: (newLeftView) =>
    @getLeftPane().append(newLeftView.el)
    newLeftView.render()
    newLeftView.makeActive()

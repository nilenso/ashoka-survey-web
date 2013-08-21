class SurveyBuilderV2.Views.AnswerTypeSwitcher
  constructor: (@source, @originalView, @attributes) ->
    
  getLeftPane: => $(".survey-panes-left-pane")
    
  switch: (event) =>
    option = $(event.target).val()
    if option == @source
      return
      
    if option == "NumericQuestion"
      newView = new SurveyBuilderV2.Views.LeftPane.NumericQuestionView(@newLeftPaneParams())
      @getLeftPane().append(newView.el)
      @originalView.remove()
      newView.render()
      newView.makeActive()
    
  newLeftPaneParams: =>
    { el: @attributes.attributes.el, question: @attributes.attributes.question }
  
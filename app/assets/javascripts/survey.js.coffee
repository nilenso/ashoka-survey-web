class SurveyBuilder
  constructor: (@sidebar_div, @form_div) ->
    @question_count = 0
    @sidebar_div.find(".add_question_field").click(@add_new_question)
    @sidebar_div.find('.tabs li').click(@switch_tabs)

  add_new_question: =>
    template = Mustache.render($('#question_template').html(), id: @question_count++)
    @form_div.find('#questions').append(template)

  switch_tabs: (event) =>
    clicked_tab = $(event.target)
    @sidebar_div.children('div').hide()
    clicked_tab_target = $(clicked_tab.data('tab-target'))
    clicked_tab_target.show()

SurveyApp.SurveyBuilder = SurveyBuilder
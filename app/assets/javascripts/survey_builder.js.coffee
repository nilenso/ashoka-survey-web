# Collection of SurveyElements

class SurveyBuilder

  constructor: (@sidebar_div, @dummy_div, @question_count) ->
    @sidebar_div.find(".add_question_field").click(@add_new_question)
    @elements = []

  add_new_question: =>
    type = $(event.target).data('type')
    actual = $(Mustache.render(@sidebar_div.find("##{type}_question_template").html(), id: @question_count))
    dummy = $(Mustache.render(@sidebar_div.find("##{type}_dummy_question_template").html(), id: @question_count++))
    @sidebar_div.find('#questions').append(actual)
    @sidebar_div.find('#questions').find('fieldset').hide()
    @dummy_div.find('#dummy_questions').append(dummy)
    @create_element(actual,dummy)

  show_element: (event) =>
    @hide_all_elements()
    event.data.element.show()
    @click_settings_tab()

  hide_all_elements: =>
    element.hide() for element in @elements

  create_element: (actual, dummy) =>
    element = new SurveyApp.SurveyElement(actual, dummy);
    @elements.push(element)
    dummy.bind('click', { element: element }, @show_element)

  click_settings_tab: =>
    $(".tabs li").last().click()

SurveyApp.SurveyBuilder = SurveyBuilder
# Container of list of available question types that can be added
class SurveyBuilder.Views.PickerPaneView extends Backbone.View
  el: "#picker_pane"

  events:
    'click #add_radio_question': 'add_radio_question'
    'click #add_single_line_question': 'add_single_line_question'
    'click #add_multiline_question': 'add_multiline_question'

  add_radio_question: ->
    $(this.el).trigger('new_question', 'radio')

  add_single_line_question: ->
    $(this.el).trigger('new_question', 'single_line')

  add_multiline_question: ->
    $(this.el).trigger('new_question', 'multiline')


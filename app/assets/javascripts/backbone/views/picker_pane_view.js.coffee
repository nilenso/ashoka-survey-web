class SurveyBuilder.Views.PickerPaneView extends Backbone.View
  el: "#picker_pane"

  events:
    'click #add_radio_question': 'add_radio_question'

  add_radio_question: ->
    $(this.el).trigger('new_question', 'radio')


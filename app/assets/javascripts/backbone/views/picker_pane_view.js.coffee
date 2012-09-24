# Container of list of available question types that can be added
class SurveyBuilder.Views.PickerPaneView extends Backbone.View
  el: "#picker_pane"

  events:
    'click #add_radio_question': 'add_radio_question'
    'click #add_single_line_question': 'add_single_line_question'
    'click #add_multiline_question': 'add_multiline_question'
    'click #add_numeric_question': 'add_numeric_question'
    'click #add_date_question': 'add_date_question'
    'click #add_multi_choice_question': 'add_multi_choice_question'
    'click #add_drop_down_question': 'add_drop_down_question'
    'click #add_photo_question': 'add_photo_question'
    'click #add_rating_question': 'add_rating_question'

  add_radio_question: ->
    $(this.el).trigger('new_question', 'RadioQuestion')

  add_single_line_question: ->
    $(this.el).trigger('new_question', 'SingleLineQuestion')

  add_multiline_question: ->
    $(this.el).trigger('new_question', 'MultilineQuestion')

  add_numeric_question: ->
    $(this.el).trigger('new_question', 'NumericQuestion')

  add_date_question: ->
    $(this.el).trigger('new_question', 'DateQuestion')

  add_multi_choice_question: ->
    $(this.el).trigger('new_question', 'MultiChoiceQuestion')

  add_drop_down_question: ->
    $(this.el).trigger('new_question', 'DropDownQuestion')

  add_photo_question: ->
    $(this.el).trigger('new_question', 'PhotoQuestion')

  add_rating_question: ->
    $(this.el).trigger('new_question', 'RatingQuestion')
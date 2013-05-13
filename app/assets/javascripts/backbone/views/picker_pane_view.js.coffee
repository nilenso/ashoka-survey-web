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
    'click #add_category': 'add_category'
    'click #add_multi_record_category': 'add_multi_record_category'

  initialize: (@survey_frozen) =>

  add_radio_question: =>
    $(this.el).trigger('new_question', { type: 'RadioQuestion' }) if @confirm_if_frozen()

  add_single_line_question: =>
    $(this.el).trigger('new_question', { type: 'SingleLineQuestion' }) if @confirm_if_frozen()

  add_multiline_question: =>
    $(this.el).trigger('new_question', { type: 'MultilineQuestion' }) if @confirm_if_frozen()

  add_numeric_question: =>
    $(this.el).trigger('new_question', { type: 'NumericQuestion' }) if @confirm_if_frozen()

  add_date_question: =>
    $(this.el).trigger('new_question', { type: 'DateQuestion' }) if @confirm_if_frozen()

  add_multi_choice_question: =>
    $(this.el).trigger('new_question', { type: 'MultiChoiceQuestion' }) if @confirm_if_frozen()

  add_drop_down_question: =>
    $(this.el).trigger('new_question', { type: 'DropDownQuestion' }) if @confirm_if_frozen()

  add_photo_question: =>
    $(this.el).trigger('new_question', { type: 'PhotoQuestion' }) if @confirm_if_frozen()

  add_rating_question: =>
    $(this.el).trigger('new_question', { type: 'RatingQuestion' }) if @confirm_if_frozen()

  add_category: =>
    $(this.el).trigger('new_category') if @confirm_if_frozen()

  add_multi_record_category: =>
    $(this.el).trigger('new_question', { type: 'MultiRecordCategory' }) if @confirm_if_frozen()

  confirm_if_frozen: =>
    if @survey_frozen then confirm(I18n.t('js.confirm_add_question_to_finalized_survey')) else true

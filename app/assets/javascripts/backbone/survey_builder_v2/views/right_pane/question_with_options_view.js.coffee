class SurveyBuilderV2.Views.RightPane.QuestionWithOptionsView extends SurveyBuilderV2.Backbone.View
  el: '.survey-panes-right-pane'

  initialize: (attributes) =>
    @model = attributes.model
    @leftPaneView = attributes.leftPaneView

    @savingIndicator = new SurveyBuilderV2.Views.SavingIndicatorView
    @model.on("change:errors", @render)
    @template = SMT[this.templatePath()]

  render:(offset) =>
    this.delegateEvents()

    this.$el.html(@template(@model.attributes))
    @setMargin(offset)
    @selectType()

    return this

  templatePath: =>
    "v2_survey_builder/surveys/right_pane/question_with_options"

  selectType: =>
    this.$el.find(".question-answer-type-select").find("option[value=#{@viewType()}]").attr("selected", true)

  setMargin: (offset) =>
    headerHeight = this.$el.offset().top
    this.$el.find(".question").css('margin-top', offset - headerHeight)

  updateModelSettings: (event) =>
    key = $(event.target).attr('id')
    value = $(event.target).is(':checked')
    @model.set(key, value)

  saveQuestion: =>
    @savingIndicator.show()
    @model.save({}, success: @handleUpdateSuccess, error: @handleUpdateError)
    _.delay(@saveOptions, 1000);

  saveOptions: =>
    @model.get('options').each (option) =>
      option.save(question_id: @model.get('id'))

  handleUpdateSuccess: (model, response, options) =>
    @model.unset("errors")
    @savingIndicator.hide()

  handleUpdateError: (model, response, options) =>
    @model.set(JSON.parse(response.responseText))
    @savingIndicator.error()

  updateView: (event) =>
    SurveyBuilderV2.Views.AnswerTypeSwitcher.switch(@viewType(), event, @leftPaneView, @model.dup())

  destroyView: =>
    this.undelegateEvents();
    this.$el.removeData().unbind();
    this.remove();
    Backbone.View.prototype.remove.call(this);

  addOptionsInBulk: (event) =>
    csv = $(event.target).val()
    parsed_csv = $.csv.toArray(csv)

    for option in parsed_csv
      @model.createNewOption(option.trim()) if option && option.length > 0

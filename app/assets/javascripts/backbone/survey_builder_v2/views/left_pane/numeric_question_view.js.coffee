class SurveyBuilderV2.Views.LeftPane.NumericQuestionView extends SurveyBuilderV2.Backbone.View
  tagName: "div"
  className: "question"
  events:
    "click": "makeActive"

  initialize: (attributes) =>
    @attributes = attributes
    @model = new SurveyBuilderV2.Models.NumericQuestionModel(@attributes.question)
    @model.on("sync", @render)
    @template = SMT["v2_survey_builder/surveys/left_pane/numeric_question"]

  render: =>
    this.$el.html(@template(@model.attributes))
    return this

  makeActive: =>
    @trigger("clear_left_pane_selections", this)
    this.$el.addClass("active")
    @right_pane_view = 
      new SurveyBuilderV2.Views.RightPane.NumericQuestionView(model: @model, offset: @getOffset())
    @right_pane_view.render()

  getOffset: =>
    this.$el.offset().top - parseInt(this.$el.css("margin-top"))

  deselect: =>
    this.$el.removeClass("active")
    @right_pane_view.undelegateEvents()

class SurveyBuilderV2.Views.LeftPane.QuestionView extends SurveyBuilderV2.Backbone.View
  tagName: "div"
  className: "question"
  events:
    "click": "makeActive"

  initialize: (attributes) =>
    @attributes = attributes
    @model.on("sync", @render)

  render: =>
    this.$el.html(@template(@model.attributes))
    return this

  makeActive: =>
    @trigger("clear_left_pane_selections", this)
    this.$el.addClass("active")
    @showRightView()

  showRightView: =>
    @right_pane_view = @createRightView() unless @right_pane_view
    @right_pane_view.render()

  getOffset: =>
    this.$el.offset().top - parseInt(this.$el.css("margin-top"))

  deselect: =>
    this.$el.removeClass("active")
    @right_pane_view.undelegateEvents()

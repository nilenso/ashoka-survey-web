class SurveyBuilderV2.Views.LeftPane.QuestionView extends SurveyBuilderV2.Backbone.View
  tagName: "div"
  className: "question"

  getRightPane: => $(".survey-panes-right-pane")

  initialize: (attributes) =>
    @attributes = attributes
    @model.on("sync", @render)

  render: =>
    this.$el.html(@template(@model.attributes))
    return this

  makeActive: =>
    globalMessageBus.trigger("clear_left_pane_selections", this)
    this.$el.addClass("active")
    @showRightView()

  showRightView: =>
    @rightPaneView.render(@getOffset())

  getOffset: =>
    this.$el.offset().top - parseInt(this.$el.css("margin-top"))

  deselect: =>
    this.$el.removeClass("active")
    @rightPaneView.undelegateEvents()

  destroy: =>
    @model.destroy()
    @destroyView()

  destroyQuestion: (event) =>
    event.stopPropagation()

    @rightPaneView.destroyQuestion()
    @destroy()

  destroyAll: =>
    @rightPaneView.destroyView()
    @destroy()

  destroyView: =>
    this.undelegateEvents()
    this.$el.removeData().unbind()
    this.remove()
    SurveyBuilderV2.Backbone.View.prototype.remove.call(this)

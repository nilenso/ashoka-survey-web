class SurveyBuilderV2.Views.LeftPane.OptionView extends SurveyBuilderV2.Backbone.View
  tagName: "div"
  className: "question-option"

  render: =>
    this.$el.append(@template(@model.attributes))
    return this

  destroyOption: =>
    @model.destroy()
    this.undelegateEvents()
    this.$el.removeData().unbind()
    this.remove()
    SurveyBuilderV2.Backbone.View.prototype.remove.call(this)
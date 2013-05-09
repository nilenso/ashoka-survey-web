class SurveyBuilder.Views.ActionsView extends Backbone.View
  el: "#actions"

  limit_edit: =>
    $(this.el).find(":input").attr("disabled", true)
    $(this.el).find(".delete-survey").remove()

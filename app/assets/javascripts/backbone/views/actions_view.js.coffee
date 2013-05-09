class SurveyBuilder.Views.ActionsView extends Backbone.View
  el: "#actions"

  freeze_view: =>
    $(this.el).find(":input").attr("disabled", true)
    $(this.el).find(".delete-survey").remove()

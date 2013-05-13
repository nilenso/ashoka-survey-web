class SurveyBuilder.Views.ActionsView extends Backbone.View
  el: "#actions"

  initialize: (survey_frozen) =>
    @limit_edit() if survey_frozen

  limit_edit: =>
    $(this.el).find(":input").attr("disabled", true)
    $(this.el).find("#save").attr("disabled", false)
    $(this.el).find(".delete-survey").remove()

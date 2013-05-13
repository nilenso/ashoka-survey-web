SurveyBuilder.Views.Questions ||= {}

# The settings of a single category in the DOM
class SurveyBuilder.Views.Questions.MultiRecordCategoryView extends SurveyBuilder.Views.Questions.CategoryView
  limit_edit: =>
    super
    $(this.el).find("input[name=mandatory]").parent('div').hide()

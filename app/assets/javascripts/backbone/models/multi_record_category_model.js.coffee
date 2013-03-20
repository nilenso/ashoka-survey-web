# Interfaces between the views and the rails model for a multiline category
class SurveyBuilder.Models.MultiRecordCategoryModel extends SurveyBuilder.Models.CategoryModel

  initialize: =>
    super
    this.set('content', I18n.t('js.untitled_multi_record_category'))

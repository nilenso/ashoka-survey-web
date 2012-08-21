class SurveyRow
  constructor: (@description_cell) ->
    @description_cell.find(".more_description_link").click(@toggle_description)
    @description_cell.find(".less_description_link").click(@toggle_description)

  toggle_description: =>
    @description_cell.find('.more_description').toggle();
    @description_cell.find('.truncated_description').toggle();
    @description_cell.find('.more_description_link').toggle();
    @description_cell.find('.less_description_link').toggle();


SurveyApp.SurveyRow = SurveyRow
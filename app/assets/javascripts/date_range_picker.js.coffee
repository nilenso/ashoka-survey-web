class SurveyApp.DateRangePicker
  constructor: (@container) ->
    date_format = "yy-mm-dd"
    @from = @container.find(".from-date").datepicker({ dateFormat: date_format })
    @to = @container.find(".to-date").datepicker({ dateFormat: date_format })
    @toggle = @container.find("#date-range-checkbox")
    @toggle.click(@toggle_date_pickers)

  toggle_date_pickers:  =>
    pickers = @container.find(".date-picker")
    if pickers.attr('disabled')
      pickers.removeAttr('disabled')
    else
      pickers.attr('disabled', 'disabled')

  prepare_params: =>
    if @toggle.attr('checked')
      from: @from.val()
      to: @to.val()
    else
      {}



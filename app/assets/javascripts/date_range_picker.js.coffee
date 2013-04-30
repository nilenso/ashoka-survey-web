class SurveyApp.DateRangePicker
  constructor: (@container) ->
    @errors = []
    date_format = "yy-mm-dd"
    @from = @container.find(".from-date").datepicker({ dateFormat: date_format })
    @to = @container.find(".to-date").datepicker({ dateFormat: date_format })
    @toggle = @container.find("#date-range-checkbox")
    @toggle.click(@toggle_date_pickers)
    @pickers = @container.find(".date-picker")

  toggle_date_pickers:  =>
    if @toggle.attr('checked')
      @pickers.removeAttr('disabled')
    else
      @pickers.attr('disabled', 'disabled')

  prepare_params: =>
    if @toggle.attr('checked')
      from: @from.val()
      to: @to.val()
    else
      {}

  both_dates_present: =>
    valid = !_(@from.val()).isEmpty() && !_(@to.val()).isEmpty()
    @errors.push "You need to add both dates." unless valid
    valid

  from_less_than_to: =>
    valid = @from.datepicker("getDate") <= @to.datepicker("getDate")
    @errors.push "From date must precede To date." unless valid
    valid

  is_valid: =>
    @errors = []
    if @toggle.attr('checked')
      if @both_dates_present() && @from_less_than_to()
        true
    else
      true

  reset: =>
    @from.val('')
    @to.val('')
    @toggle.removeAttr('checked')
    @pickers.attr("disabled", "disabled")


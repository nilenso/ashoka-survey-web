class SurveyApp.ExcelPasswordDialog
  constructor: (@password) ->
    $("#excel-password-dialog .password").text(@password)

  show: =>
    @dialog = $("#excel-password-dialog").dialog
      dialogClass: "no-close"
      modal: true
      width: 600
      buttons: [ text: "Ok", click: -> $(this).dialog("close") ]


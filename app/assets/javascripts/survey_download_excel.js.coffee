class window.ExcelDownloader
  constructor: (survey_id) ->
    $('.download_excel').click ->
      $( "#dialog" ).dialog
        dialogClass: "no-close"
      $.getJSON("/surveys/#{survey_id}/responses/generate_excel", (data) =>
        console.log(data)
        # poll
      )


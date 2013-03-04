class window.ExcelDownloader
  constructor: (survey_id) ->
    $('.download_excel').click ->
      $.getJSON("/surveys/#{survey_id}/responses/generate_excel", (data) =>
        console.log(data)
        # Dialog box saying downloading
        # poll
      )


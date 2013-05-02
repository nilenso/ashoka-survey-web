class SurveyApp.URLShortener
  shorten: (url, success, failure) =>
    $.getJSON "http://api.bitly.com/v3/shorten",
      format: 'json'
      apiKey: SurveyApp.Settings.BITLY_API_KEY
      longUrl: url
      login: SurveyApp.Settings.BITLY_USERNAME
    , (response) =>
      if response.status_code >= 400
        console.log("Error while shortening URL")
        console.log(response)
        failure && failure(response)
      else
        console.log("Successfully shortened #{url} to #{response.data.url}")
        success && success(response.data)

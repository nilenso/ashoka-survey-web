describe "SurveyRow", ->
  beforeEach ->
    loadFixtures "survey_row"
    new SurveyApp.SurveyRow($(".survey_description_1"))

  describe "when clicked on more description link", ->
    it "shows more description, less description link and hides truncated description", ->
      $(".more_description").hide()
      $(".less_description_link").hide()
      $(".more_description_link").click()
      expect($(".more_description")).toBeVisible()  
      expect($(".less_description_link")).toBeVisible()  
      expect($(".truncated_description")).toBeHidden()  

  describe "when clicked on less description link", ->
    it "hides more description, less description link and shows truncated description", ->
      $('.truncated_description').hide()
      $(".less_description_link").click()
      expect($(".more_description")).toBeHidden()  
      expect($(".less_description_link")).toBeHidden()
      expect($(".truncated_description")).toBeVisible()  
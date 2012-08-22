describe 'SurveyBuilder', js: true do
  context "when clicking on 'Add New Question'" do
    it "adds a question to the questions div on clicking the link" do
      visit('/surveys/new')
      click_link("Add a single line Question")
      find("#questions").should have_selector('fieldset')
      fieldset = find("#questions").first('fieldset')
      fieldset.should have_field('survey[questions_attributes][0][content]')
      fieldset.should have_field('survey_questions_attributes_0_content')
      fieldset.should have_selector('label')
    end

    it "adds multiple questions when the link is clicked multiple times" do
      visit('/surveys/new')
      click_link("Add a single line Question")
      click_link("Add a single line Question")
      find("#questions").all('fieldset').should have(2).fieldsets
    end

    it "stores the count of questions added in the name attribute of the input" do
      visit('/surveys/new')
      click_link("Add a single line Question")
      click_link("Add a single line Question")
      
      find("#questions").all('input').each_with_index do |input, i| 
        input[:name].should include(i.to_s)
      end
    end
  end
end

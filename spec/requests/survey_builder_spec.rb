describe 'SurveyBuilder', js: true do
  context "when clicking on 'Add New Question'" do
    it "adds a question to the questions div on clicking the link" do
      visit('/surveys/new')
      click_link("Add a single line Question")
      find("#questions").should have_selector('fieldset')
    end

    it "adds multiple questions when the link is clicked multiple times" do
      visit('/surveys/new')
      click_link("Add a single line Question")
      click_link("Add a single line Question")
      find("#questions").all('fieldset').each.count.should == 2
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

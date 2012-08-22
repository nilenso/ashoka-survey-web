describe 'SurveyBuilder', js: true do
  context "when clicking on 'Add New Question'" do
    it "adds a question to the questions div on clicking the link" do
      visit('/surveys/new')
      click_link("Add a single line Question")
      find("#questions").should have_selector('fieldset')
      fieldset = find("#questions").first('fieldset')
      fieldset.should have_selector('label')
      fieldset.should have_selector('input')
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

  context "when submitting the form" do
    it "saves the survey details to the database" do
      visit('/surveys/new')
      within('#survey_details') do
        fill_in('Name', :with => 'Sample survey')

        select('2012', :from => 'Year')
        select('July', :from => 'Month')
        select('22',   :from => 'Day')

        fill_in('Description', :with => 'Hello')
      end
      click_on('Create Survey')

      survey = Survey.find_by_name('Sample survey')
      survey.should_not be_nil
      survey.expiry_date.strftime('%Y-%m-%d').should == '2012-07-22'
      survey.description.should == 'Hello'
    end
    after(:each) do
      Survey.delete_all
      Question.delete_all
    end
  end
end

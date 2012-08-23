describe 'SurveyBuilder', js: true do
  context "when clicking on 'Add New Question'" do
    before(:each) do
      visit('/surveys/new')
      click_link("Add a single line Question")
    end

    it "adds a question to the questions div on clicking the link" do
      find("#questions").should have_selector('fieldset')
      fieldset = find("#questions").first('fieldset')
      fieldset.should have_selector('label')
      fieldset.should have_selector('input')
    end

    it "adds a dummy question to the dummy form display" do
      find("#dummy_questions").should have_selector('input')
    end

    it "adds multiple questions when the link is clicked multiple times" do
      click_link("Add a single line Question")
      find("#questions").all('fieldset').should have(2).fieldsets
    end

    it "stores the count of questions added in the name attribute of the input" do
      click_link("Add a single line Question")
      
      find("#questions").all('fieldset').each_with_index do |fieldset, i| 
        fieldset.all('input').each do |input|
          input[:name].should include(i.to_s)
        end
      end
    end

    it "doesn't show the questions added in the sidebar" do
      within("#questions") do
        find('fieldset')['style'].should == "display: none; "
      end
    end
  end

  context "when submitting the form" do
    before(:each) do
      Survey.delete_all
      Question.delete_all
    end

    it "saves the survey details to the database" do
      visit('/surveys/new')
      find('li', :text => 'Settings').click
      within('#survey_details') do
        fill_in('Name', :with => 'Sample survey')
        find_field('Expires on').set("2012/07/22")
        find_field('Name').click # To hide the datepicker
        fill_in('Description', :with => 'Hello')
      end
      click_on('Create Survey')

      survey = Survey.find_by_name('Sample survey')
      survey.should_not be_nil
      survey.expiry_date.strftime('%Y-%m-%d').should == '2012-07-22'
      survey.description.should == 'Hello'
    end

    context "with questions" do
      before(:each) do
        visit('/surveys/new')
        find('li', :text => 'Settings').click
        within('#survey_details') do
          fill_in('Name', :with => 'Another sample survey')
          fill_in('Expires on', :with => '2012/06/07')
          find_field('Name').click # To hide the datepicker
        end
      end

      it "saves a single line question" do
        find('li', :text => 'Pick Question').click
        click_on('Add a single line Question')
        find('li', :text => 'Settings').click
        find('#dummy_questions').find('fieldset').click

        fill_in('Content', :with => 'Test question?')
        fill_in('Max length', :with => 100)
        check('Mandatory')
        click_on('Create Survey')

        survey = Survey.find_by_name('Another sample survey')
        question = Question.find_by_content('Test question?')
        question.should_not be_nil
        survey.questions.should include question
      end
    end
  end
end

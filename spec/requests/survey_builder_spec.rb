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
        find('#dummy_questions').find('fieldset').click

        fill_in('Content', :with => 'Test question?')
        fill_in('Max length', :with => 100)
        check('Mandatory')
        # attach_file('Image', 'app/assets/images/rails.png')
        click_on('Create Survey')


        survey = Survey.find_by_name('Another sample survey')
        question = SingleLineQuestion.find_by_content('Test question?')
        question.should_not be_nil
        survey.questions.should include question
      end
    end

    context "without required fields" do
      before(:each) do
        visit('/surveys/new')
        click_on('Add a single line Question')
        click_on('Add a single line Question')
        find('#dummy_questions').first('fieldset').click
        fill_in('Content', :with => 'A question?')
        click_on('Create Survey')
      end

      it "returns the form with the added actual and dummy fields" do
        find("#questions").all('fieldset').should have(2).fieldsets
        find("#dummy_questions").all('fieldset').should have(2).fieldsets
      end

      it "restores the content of the dummy fields" do
        find("#dummy_questions").should have_content('A question?')
      end

      it "shows errors where appropriate" do
        find("#dummy_survey_details").should have_content('Name can\'t be blank')
        find("#dummy_survey_details").should have_content('Expires on can\'t be blank')
        find("#dummy_questions").should have_content('Content can\'t be blank')
      end

      it "allows adding more questions to the form" do
        click_on('Add a single line Question')
        find("#questions").all('fieldset').should have(3).fieldsets
        find("#dummy_questions").all('fieldset').should have(3).fieldsets
      end

      it "saves the survey successfully after filling required fields" do
        find("#dummy_survey_details").click
        within('#survey_details') do
          fill_in('Name', :with => 'foo survey')
          fill_in('Expires on', :with => '2012/06/07')
          find_field('Name').click # To hide the datepicker
        end
        find("#dummy_question_1").click
        fill_in('Content', :with => 'foo question?')
        click_on('Create Survey')

        survey = Survey.find_by_name('foo survey')
        survey.should_not be_nil
        question_1 = SingleLineQuestion.find_by_content('A question?')
        question_2 = SingleLineQuestion.find_by_content('foo question?')
        question_1.should_not be_nil
        question_2.should_not be_nil
        survey.questions.should include question_1
        survey.questions.should include question_2
      end
    end
  end

  context "in the dummy form display" do
    context "when clicking on the survey heading section" do
      before(:each) { visit('/surveys/new') }

      it "shows the survey settings" do
        find("#dummy_survey_details").click
        find('#settings_pane').should have_content('Name')
        find('#settings_pane').should have_content('Expires on')
        find('#settings_pane').should have_content('Description')
      end

      it "highlights itself" do
        find("#dummy_survey_details").click
        find("#dummy_survey_details")['class'].should == 'details_active'
      end
    end

    context "when clicking on a question" do
      before(:each) do
        visit('/surveys/new')
        click_on('Add a single line Question')
      end

      it "shows the settings for that question" do
        find("#dummy_questions").find('fieldset').click
        find('#settings_pane').should have_content('Content')
        find('#settings_pane').should have_content('Max length')
        find('#settings_pane').should have_content('Image')
      end

      it "clears the settings pane of previous content" do
        find("#dummy_survey_details").click
        find("#dummy_questions").find('fieldset').click
        find('#survey_details')['style'].should include 'display: none;'
      end

      it "highlights itself" do
        find("#dummy_questions").find('fieldset').click
        find("#dummy_questions").find('fieldset')['class'].should == 'active'
      end

      it "removes all other highlights in the dummy form display" do
        click_on('Add a single line Question')
        first_question, last_question = find("#dummy_questions").all('fieldset').to_a
        first_question.click
        last_question.click
        first_question['class'].should_not == 'active'
        last_question['class'].should == 'active'
      end
    end
  end
end

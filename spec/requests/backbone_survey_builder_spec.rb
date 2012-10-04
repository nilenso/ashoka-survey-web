describe 'BackboneSurveyBuilder', js: true do
  self.use_transactional_fixtures = false

  def wait_until_ajax_stop
    find('#spinner').has_no_selector?('div') # Wait until spinner disappears
  end

  context "when adding a new radio question" do
    before(:each) do
      @survey = FactoryGirl.create(:survey)
      visit(surveys_build_path(:id => @survey.id))
      click_on('Radio Question')
      wait_until_ajax_stop
    end

    it "should create a new question in the database" do
      question = Question.find_by_survey_id(@survey.id)
      question.should_not be_nil
      question.type.should == "RadioQuestion"
    end

    it "should add a radio question in the dummy" do
      dummy = find("#dummy_pane").find('div[type=RadioQuestion]')
      dummy.should_not be_nil
      dummy.should have_content("Untitled question")
      dummy.should have_content("First Option")
      dummy.should have_content("Second Option")
      dummy.should have_content("Third Option")
    end

    it "should add a hidden radio question in the settings pane" do
      actual = find("#settings_pane").find('div[type=RadioQuestion]')
      actual['type'].should == "RadioQuestion"
      actual['style'].should == "display: none; "
      actual.should have_button("Add Option")
      actual.should have_field('content', :type => 'text')
      actual.should have_field('mandatory', :type => 'checkbox')
      actual.should have_field('image', :type => 'file')
      actual.should have_content("Option")
      actual.should have_selector('input', :count => 6 )
    end

    context "when clicking on a dummy" do
      it "should show a radio question in the settings pane" do
        find("#dummy_pane").find('div').click
        find("#settings_pane").find('div')['style'].should == "display: block; "
      end
    end

    context "when saving" do
      it "saves a question successfully" do
        find("#dummy_pane").find('div').click
        within("#settings_pane") do
          fill_in('content', :with => 'Some question')
          check('mandatory')
        end
        find("#save").click
        wait_until_ajax_stop
        question = Question.find_by_survey_id(@survey.id)
        question.content.should == "Some question"
        question.mandatory.should be_true
        question.options.length.should == 3
      end

      it "saves all options for a question" do
        find("#dummy_pane").find('div').click
        within("#settings_pane") do
          click_on('Add Option')
          click_on('Add Option')
        end
        wait_until_ajax_stop
        find("#save").click
        wait_until_ajax_stop
        question = Question.find_by_survey_id(@survey.id)
        question.options.length.should == 5
      end
    end
  end
  context "when adding a new single line question" do
    before(:each) do
      @survey = FactoryGirl.create(:survey)
      visit(surveys_build_path(:id => @survey.id))
      click_on('Single Line Question')
      wait_until_ajax_stop
    end

    it "should create a new question in the database" do
      wait_until_ajax_stop
      question = Question.find_by_survey_id(@survey.id)
      question.should_not be_nil
      question.type.should == "SingleLineQuestion"
    end

    it "should add a single line question in the dummy" do
      dummy = find("#dummy_pane").find('div[type=SingleLineQuestion]')
      dummy.should_not be_nil
      dummy.should have_content("Untitled question")
    end

    it "should add a hidden single line question in the settings pane" do
      actual = find("#settings_pane").find('div[type=SingleLineQuestion]')
      actual.should_not be_nil
      actual['style'].should == "display: none; "
      actual.should have_field('content', :type => 'text')
      actual.should have_field('mandatory', :type => 'checkbox')
      actual.should have_field('image', :type => 'file')
    end

    context "when clicking on a dummy" do
      it "should show a single line question in the settings pane" do
        find("#dummy_pane").find('div').click
        find("#settings_pane").find('div')['style'].should == "display: block; "
      end
    end

    context "when saving" do
      it "saves a question successfully" do
        find("#dummy_pane").find('div').click
        within("#settings_pane") do
          fill_in('content', :with => 'Some question')
          check('mandatory')
        end
        find("#save").click
        wait_until_ajax_stop
        question = Question.find_by_survey_id(@survey.id)
        question.content.should == "Some question"
        question.mandatory.should be_true
      end
    end
  end
end

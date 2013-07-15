require 'cancan/matchers'

describe SupervisorAbility do
  subject { ability }
  let(:user_info) {
    {
        :name => 'John',
        :email => 'john@gmail.com',
        :org_id => 5,
        :user_id => 6,
        :session_token => 'rdsfgasidufyas',
        :role => 'supervisor'
    }
  }
  let(:ability){ SupervisorAbility.new(user_info) }

  context "for surveys" do
    let(:survey_published_to_him) do
      survey = FactoryGirl.create :survey, :finalized, :organization_id => user_info[:org_id]
      SurveyUser.create(:user_id => 6, :survey_id => survey.id)
      survey
    end
    let(:survey_not_published_to_him) { FactoryGirl.create :survey, :finalized, :organization_id => 5 }

    it { should_not be_able_to :create, Survey }
    it { should_not be_able_to :update, Survey }
    it { should_not be_able_to :build, Survey }
    it { should_not be_able_to :destroy, Survey }
    it { should_not be_able_to :duplicate, Survey }
    it { should_not be_able_to :manage, Survey }

    it { should be_able_to :archive, survey_published_to_him }
    it { should_not be_able_to :archive, survey_not_published_to_him }

    it { should be_able_to :generate_excel, survey_published_to_him }
    it { should_not be_able_to :generate_excel, survey_not_published_to_him }

    it { should be_able_to :report, survey_published_to_him }
    it { should_not be_able_to :report, survey_not_published_to_him }

    it { should be_able_to :read, survey_published_to_him }
    it { should_not be_able_to :read, survey_not_published_to_him }

    it { should_not be_able_to :change_excel_filters, survey_published_to_him }
    it { should_not be_able_to :change_excel_filters, survey_not_published_to_him }

    it { should be_able_to :view_survey_dashboard, survey_published_to_him }
    it { should_not be_able_to :view_survey_dashboard, survey_not_published_to_him }

    context "with responses" do
      let(:response_for_survey_published_to_him) { FactoryGirl.create(:response, :survey => survey_published_to_him) }
      let(:response_for_survey_not_published_to_him) { FactoryGirl.create(:response, :survey => survey_not_published_to_him) }

      it { should be_able_to :create, Response.new(:survey => survey_published_to_him) }
      it { should_not be_able_to :create, Response.new(:survey => survey_not_published_to_him) }

      it { should be_able_to :manage, response_for_survey_published_to_him }
      it { should_not be_able_to :manage, response_for_survey_not_published_to_him }
    end

    context "when publishing/sharing" do
      it { should_not be_able_to :edit_publication, Survey }
      it { should_not be_able_to :update_publication, Survey }
    end
  end
end

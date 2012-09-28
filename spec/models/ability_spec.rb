require "cancan/matchers"

describe "Abilities" do
  subject { ability }
  let(:base_user_info) {
    {
      :name => "John",
      :email => "john@gmail.com",
      :org_id => 5,
      :user_id => 6
    }
  }
  let(:ability){ Ability.new(user_info) }

  context "for Surveys" do
    context "when is a admin" do
      let(:user_info) { base_user_info.merge(:role => 'admin') }

      it { should be_able_to(:read, Survey.new) }
      it { should be_able_to(:create, Survey.new) }
      it { should be_able_to(:publish, Survey.new) }
      it { should be_able_to(:edit, Survey.new) }
      it { should be_able_to(:share, Survey.new) }
      it { should be_able_to(:destroy, Survey.new) }
      it { should be_able_to(:build, Survey.new) }

      it { should be_able_to(:create, Response.new)}
      it { should be_able_to(:read, Response.new)}
    end

    context "when is a cso admin" do
      let(:user_info) { base_user_info.merge(:role => 'cso_admin') }

      it { should be_able_to(:create, Survey.new) }

      context "for surveys belonging to the same organization" do
        let(:survey) { survey = FactoryGirl.create(:survey, :organization_id => 5) }

        it { should be_able_to(:edit, survey) }
        it { should be_able_to(:share, survey) }
        it { should be_able_to(:build, survey) }
        it { should be_able_to(:destroy, survey) }
        it { should be_able_to(:read, survey) }
        it { should be_able_to(:publish, survey) }

        it { should be_able_to :create, Response.new(:survey => survey) }
        it { should be_able_to :read, Response.new(:survey => survey) }
      end

      context "for surveys belonging to another organization" do
        let(:survey) { FactoryGirl.create(:survey, :organization_id => 6) }

        it { should_not be_able_to(:edit, survey) }
        it { should_not be_able_to(:share, survey) }
        it { should_not be_able_to(:build, survey) }
        it { should_not be_able_to(:publish, survey) }
        it { should_not be_able_to(:destroy, survey) }
        it { should_not be_able_to(:read, survey) }

        it { should_not be_able_to :create, Response.new(:survey => survey) }
        it { should_not be_able_to :read, Response.new(:survey => survey) }
      end

      context "for surveys belonging to another organization that have been shared with me" do
        let(:survey) { FactoryGirl.create(:survey, :organization_id => 50) }
        before { ParticipatingOrganization.create(:organization_id => user_info[:org_id],  :survey_id => survey.id) }

        it { should be_able_to(:read, survey) }
      end
    end

    context "when is a regular user" do
      let(:user_info) { base_user_info.merge(:role => 'user') }

      it { should_not be_able_to(:create, Survey.new) }
      it { should_not be_able_to(:publish, Survey.new) }
      it { should_not be_able_to(:edit, Survey.new) }
      it { should_not be_able_to(:share, Survey.new) }
      it { should_not be_able_to(:destroy, Survey.new) }
      it { should_not be_able_to(:build, Survey.new) }

      context "for a survey shared with him" do
        let(:survey) { FactoryGirl.create(:survey, :organization_id => 5) }
        let(:response) { FactoryGirl.create(:response, :survey_id => survey.id, :user_id => base_user_info[:user_id]) }
        before(:each) do
          SurveyUser.create(:survey_id => survey.id, :user_id => user_info[:user_id])
        end

        it { should be_able_to :read, survey }
        it { should be_able_to :create, Response.new(:survey => survey) }
        it { should be_able_to :read,  response }
      end

      context "for a survey not shared with him" do
        let(:survey) { survey = FactoryGirl.create(:survey, :organization_id => 7) }
        let(:response) { FactoryGirl.create(:response, :survey_id => survey.id, :user_id => 23423423) }
        before(:each) do
          survey = FactoryGirl.create(:survey, :organization_id => 6)
          SurveyUser.create(:survey_id => survey.id, :user_id => 123)
        end

        it { should_not be_able_to :read, survey }
        it { should_not be_able_to :create, Response.new(:survey => survey) }
        it { should_not be_able_to :read,  response }
      end
    end
  end
end

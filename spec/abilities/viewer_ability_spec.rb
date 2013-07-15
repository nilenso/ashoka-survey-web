require "cancan/matchers"

describe ViewerAbility do
  subject { ability }
  let(:user_info) {
    {
        :name => "John",
        :email => "john@gmail.com",
        :org_id => 5,
        :user_id => 6,
        :session_token => "rdsfgasidufyasd",
        :role => 'viewer'
    }
  }
  let(:ability){ ViewerAbility.new(user_info) }

  context "for surveys" do
    let(:survey_in_same_org) { FactoryGirl.create :survey, :finalized, :organization_id => user_info[:org_id] }
    let(:survey_in_other_org) { FactoryGirl.create :survey, :finalized, :organization_id => 341 }
    let(:survey_in_another_org_shared_with_his_org) do
      survey = FactoryGirl.create :survey, :finalized, :organization_id => 300
      ParticipatingOrganization.create(:survey_id => survey.id, :organization_id => 5)
      survey
    end

    it { should_not be_able_to :create, Survey }
    it { should_not be_able_to :update, Survey }
    it { should_not be_able_to :build, Survey }
    it { should_not be_able_to :destroy, Survey }
    it { should_not be_able_to :duplicate, Survey }
    it { should_not be_able_to :archive, Survey }

    it { should_not be_able_to :read, survey_in_other_org }
    it { should be_able_to :read, survey_in_same_org }

    it { should_not be_able_to :change_excel_filters, survey_in_same_org }
    it { should_not be_able_to :change_excel_filters, survey_in_another_org_shared_with_his_org }
    it { should_not be_able_to :change_excel_filters, survey_in_other_org }

    context "with responses" do
      let(:response_in_same_org) { FactoryGirl.create(:response, :organization_id => 5) }
      let(:response_in_other_org) { FactoryGirl.create(:response, :organization_id => 54) }

      let(:response_in_other_org_belonging_to_survey_in_his_organization) do
        FactoryGirl.create(:response, :organization_id => 54, :survey => survey_in_same_org)
      end

      it { should_not be_able_to :manage, Response }
      it { should_not be_able_to :manage, response_in_same_org }
      it { should_not be_able_to :manage, response_in_other_org }
      it { should_not be_able_to :manage, response_in_other_org_belonging_to_survey_in_his_organization }


      it { should be_able_to :read, response_in_same_org }
      it { should be_able_to :read, response_in_other_org_belonging_to_survey_in_his_organization }
      it { should_not be_able_to :read, response_in_other_org }
    end

    context "when publishing/sharing" do
      it { should_not be_able_to :edit_publication, Survey }
      it { should_not be_able_to :update_publication, Survey }
    end
  end
end

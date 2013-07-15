require 'cancan/matchers'

describe ManagerAbility do
  subject { ability }
  let(:user_info) {
    {
        :name => 'John',
        :email => 'john@gmail.com',
        :org_id => 5,
        :user_id => 6,
        :session_token => 'rdsfgasidufyas',
        :role => 'manager'
    }
  }
  let(:ability){ ManagerAbility.new(user_info) }

  context "for surveys" do
    let(:survey_in_his_organization) { FactoryGirl.create :survey, :finalized, :organization_id => 5 }
    let(:survey_in_another_organization) { FactoryGirl.create :survey, :finalized, :organization_id => 300 }
    let(:survey_in_another_org_shared_with_his_org) do
      survey = FactoryGirl.create :survey, :finalized, :organization_id => 300
      ParticipatingOrganization.create(:survey_id => survey.id, :organization_id => 5)
      survey
    end

    it { should be_able_to :create, FactoryGirl.build(:survey, :organization_id => 5) }
    it { should_not be_able_to :create, FactoryGirl.build(:survey, :organization_id => 6) }

    it { should be_able_to :update, survey_in_his_organization }
    it { should_not be_able_to :update, survey_in_another_org_shared_with_his_org }
    it { should_not be_able_to :update, survey_in_another_organization }

    it { should be_able_to :build, FactoryGirl.build(:survey, :organization_id => 5) }
    it { should_not be_able_to :build, FactoryGirl.build(:survey, :organization_id => 6) }

    it { should be_able_to :destroy, survey_in_his_organization }
    it { should_not be_able_to :destroy, survey_in_another_org_shared_with_his_org }
    it { should_not be_able_to :destroy, survey_in_another_organization }

    it { should be_able_to :duplicate, survey_in_his_organization }
    it { should be_able_to :duplicate, survey_in_another_org_shared_with_his_org }
    it { should_not be_able_to :duplicate, survey_in_another_organization }

    it { should be_able_to :read, survey_in_his_organization }
    it { should be_able_to :read, survey_in_another_org_shared_with_his_org }
    it { should_not be_able_to :read, survey_in_another_organization }

    it { should be_able_to :report, survey_in_his_organization }
    it { should be_able_to :report, survey_in_another_org_shared_with_his_org }
    it { should_not be_able_to :report, survey_in_another_organization }

    it { should be_able_to :generate_excel, survey_in_his_organization }
    it { should be_able_to :generate_excel, survey_in_another_org_shared_with_his_org }
    it { should_not be_able_to :generate_excel, survey_in_another_organization }

    it { should be_able_to :finalize, survey_in_his_organization }
    it { should_not be_able_to :finalize, survey_in_another_org_shared_with_his_org }
    it { should_not be_able_to :finalize, survey_in_another_organization }

    it { should be_able_to :archive, survey_in_his_organization }
    it { should_not be_able_to :archive, survey_in_another_org_shared_with_his_org }
    it { should_not be_able_to :archive, survey_in_another_organization }

    it { should be_able_to :change_excel_filters, survey_in_his_organization }
    it { should be_able_to :change_excel_filters, survey_in_another_org_shared_with_his_org }
    it { should_not be_able_to :change_excel_filters, survey_in_another_organization }

    it { should be_able_to :view_survey_dashboard, survey_in_his_organization }
    it { should_not be_able_to :view_survey_dashboard, survey_in_another_org_shared_with_his_org }
    it { should_not be_able_to :view_survey_dashboard, survey_in_another_organization }


    context "with responses" do
      let(:response_in_same_org) { FactoryGirl.create(:response, :organization_id => 5) }
      let(:response_in_other_org) { FactoryGirl.create(:response, :organization_id => 54) }

      let(:response_in_other_org_belonging_to_survey_in_his_organization) do
        FactoryGirl.create(:response, :organization_id => 54, :survey => survey_in_his_organization)
      end

      it { should be_able_to :manage, response_in_same_org }
      it { should_not be_able_to :manage, response_in_other_org }

      it { should be_able_to :manage, response_in_other_org_belonging_to_survey_in_his_organization }

      it { should be_able_to :create, Response.new(:survey => survey_in_another_org_shared_with_his_org) }
      it { should be_able_to :create, Response.new(:survey => survey_in_his_organization) }
      it { should_not be_able_to :create, Response.new(:survey => survey_in_another_organization) }
    end

    context "when publishing/sharing" do
      it { should be_able_to :edit_publication, survey_in_his_organization }
      it { should be_able_to :update_publication, survey_in_his_organization }

      it { should be_able_to :edit_publication, survey_in_another_org_shared_with_his_org }
      it { should be_able_to :update_publication, survey_in_another_org_shared_with_his_org }

      it { should_not be_able_to :edit_publication, survey_in_another_organization }
      it { should_not be_able_to :update_publication, survey_in_another_organization }
    end
  end
end


require "cancan/matchers"

describe "Abilities" do
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
    let(:survey_in_same_org) { FactoryGirl.create :survey_with_all, :organization_id => user_info[:org_id] }
    let(:survey_in_other_org) { FactoryGirl.create :survey_with_all, :organization_id => 341 }

    it { should_not be_able_to :create, Survey }
    it { should_not be_able_to :update, Survey }
    it { should_not be_able_to :build, Survey }
    it { should_not be_able_to :destroy, Survey }
    it { should_not be_able_to :duplicate, Survey }

    context "belonging to another organization" do
      it { should_not be_able_to :read, survey_in_other_org }
      it { should_not be_able_to :questions_count, survey_in_other_org }
      it { should_not be_able_to :manage, survey_in_other_org.questions[0] }
      it { should_not be_able_to :manage, survey_in_other_org.categories[0] }
      it { should_not be_able_to :manage, survey_in_other_org.questions[0].options[0] }
    end

    context "belonging to the same organization" do
      it { should be_able_to :read, survey_in_same_org }
      it { should be_able_to :questions_count, survey_in_same_org }

      it { should be_able_to :read, survey_in_same_org.questions[0] }
      it { should be_able_to :read, survey_in_same_org.questions[0].options[0] }
      it { should_not be_able_to :manage, survey_in_same_org.questions[0] }
      it { should_not be_able_to :manage, survey_in_same_org.questions[0].options[0] }

      it { should be_able_to :read, survey_in_same_org.categories[0] }
      it { should_not be_able_to :manage, survey_in_same_org.categories[0] }
    end

    context "when publishing/sharing" do
      it { should_not be_able_to :edit_publication, Survey }
      it { should_not be_able_to :update_publication, Survey }
    end
  end
end

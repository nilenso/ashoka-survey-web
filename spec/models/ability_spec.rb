require "cancan/matchers"

describe "Abilities" do
  subject { ability }
  let(:base_user_info) {
    {
      :name => "John",
      :email => "john@gmail.com",
      :org_id => 5,
      :user_id => 6,
      :session_token => "rdsfgasidufyasd"
    }
  }
  let(:ability){ Ability.new(user_info) }

  context "for Surveys" do
    context "when is a admin" do
      let(:user_info) { base_user_info.merge(:role => 'admin') }

      it { should be_able_to(:read, Survey.new) }
      it { should be_able_to(:read, Response.new)}
    end

    context "when is a cso admin" do
      let(:user_info) { base_user_info.merge(:role => 'cso_admin') }

      it { should be_able_to(:create, Survey.new) }

      context "for surveys belonging to the same organization" do
        let(:survey) { survey = FactoryGirl.create(:survey, :organization_id => 5) }
        let(:published_survey) { survey = FactoryGirl.create(:survey, :organization_id => 5, :published => true) }

        it { should be_able_to(:edit, survey) }
        it { should be_able_to(:share_with_organizations, survey) }
        it { should be_able_to(:update_share_with_organizations, survey) }
        it { should be_able_to(:build, survey) }
        it { should be_able_to(:destroy, survey) }
        it { should_not be_able_to(:destroy, published_survey) }
        it { should be_able_to(:read, survey) }
        it { should be_able_to(:publish_to_users, survey) }
        it { should be_able_to(:update_publish_to_users, survey) }
        it { should be_able_to(:report, survey) }

        it { should be_able_to :manage, Response.new(:survey => survey) }
        it { should be_able_to :complete, Response.new(:survey => survey) }
        it { should be_able_to :read, Response.new(:survey => survey) }
        it { should be_able_to :duplicate, Response.new(:survey => survey) }
      end

      context "for surveys belonging to another organization" do
        let(:survey) { FactoryGirl.create(:survey, :organization_id => 6) }

        it { should_not be_able_to(:edit, survey) }
        it { should_not be_able_to(:build, survey) }
        it { should_not be_able_to(:publish_to_users, survey) }
        it { should_not be_able_to(:update_publish_to_users, survey) }
        it { should_not be_able_to(:destroy, survey) }
        it { should_not be_able_to(:read, survey) }
        it { should_not be_able_to(:share_with_organizations, survey) }
        it { should_not be_able_to(:update_share_with_organizations, survey) }

        it { should_not be_able_to :create, Response.new(:survey => survey) }
        it { should_not be_able_to :complete, Response.new(:survey => survey) }
        it { should_not be_able_to :read, Response.new(:survey => survey) }
        it { should_not be_able_to :duplicate, Response.new(:survey => survey) }
      end

      context "for surveys belonging to another organization that have been shared with me" do
        let(:survey) { FactoryGirl.create(:survey, :organization_id => 50) }
        before { ParticipatingOrganization.create(:organization_id => user_info[:org_id],  :survey_id => survey.id) }

        it { should be_able_to(:read, survey) }
        it { should be_able_to :duplicate, survey }

        it "should be able to read responses added by members of his organizations" do
          response = Response.new(:survey => survey)
          response.organization_id = user_info[:org_id]
          should be_able_to :read, response
        end
      end
    end

    context "when is a field agent" do
      let(:user_info) { base_user_info.merge(:role => 'field_agent') }

      it { should_not be_able_to(:create, Survey.new) }
      it { should_not be_able_to(:publish_to_users, Survey.new) }
      it { should_not be_able_to(:update_publish_to_users, Survey.new) }
      it { should_not be_able_to(:edit, Survey.new) }
      it { should_not be_able_to(:share_with_organizations, Survey.new) }
      it { should_not be_able_to(:update_share_with_organizations, Survey.new) }
      it { should_not be_able_to(:destroy, Survey.new) }
      it { should_not be_able_to(:build, Survey.new) }
      it { should_not be_able_to(:duplicate, Survey) }

      context "for a survey shared with him" do
        let(:survey) { FactoryGirl.create(:survey, :organization_id => 5) }
        let(:response) { FactoryGirl.create(:response, :survey_id => survey.id, :user_id => base_user_info[:user_id], :organization_id => 1) }
        before(:each) do
          SurveyUser.create(:survey_id => survey.id, :user_id => user_info[:user_id])
        end

        it { should be_able_to :read, survey }
        it { should be_able_to :create, Response.new(:survey => survey) }
        it { should be_able_to :read,  response }
        it { should be_able_to :complete,  response }
        it { should be_able_to :destroy,  response }
      end

      context "for a survey not shared with him" do
        let(:survey) { survey = FactoryGirl.create(:survey, :organization_id => 7) }
        let(:response) { FactoryGirl.create(:response, :survey_id => survey.id, :user_id => 23423423, :organization_id => 1) }
        before(:each) do
          survey = FactoryGirl.create(:survey, :organization_id => 6)
          SurveyUser.create(:survey_id => survey.id, :user_id => 123)
        end

        it { should_not be_able_to :read, survey }
        it { should_not be_able_to :create, Response.new(:survey => survey) }
        it { should_not be_able_to :read,  response }
        it { should_not be_able_to :complete,  response }
        it { should_not be_able_to :destroy,  response }
      end
    end

    context "when is not logged in" do
      let(:public_survey) { FactoryGirl.create :survey, :public => true  }
      let(:user_info) { { :session_token => "foo" } }
      let(:response) { Response.create(:survey => public_survey) }

      context "can manage a response that he created" do
        before(:each) do
          response.session_token = "foo"
          response.save
        end

        it { should be_able_to :manage, response }
      end

      context "cannot manage a response that he didn't create" do
        before(:each) do
          response.session_token = "fooabc"
          response.save
        end

        it { should_not be_able_to :manage, response }
      end
    end


    describe "public responses" do

      base_user_info =  {
        :name => "John",
        :email => "john@gmail.com",
        :org_id => 5,
        :user_id => 6,
        :session_token => "foo"
      }


      roles =  ['admin', 'cso_admin', 'field_agent']
      user_info_array = roles.map { |role| base_user_info.merge(:role => role) }
      user_info_array = user_info_array.push({ :role => 'non-logged-in user', :session_token => "foo" })

      user_info_array.each do |user_info|
        context "a #{user_info[:role]} can manage a public response that he created" do
          before(:each) do
            public_survey = FactoryGirl.create :survey, :public => true
            @response = Response.create(:survey => public_survey)
            @response.session_token = "foo"
            @response.save
          end

          let!(:user_info) { user_info }

          it { should be_able_to :manage, @response }
        end

        context "a #{user_info[:role]} cannot manage a public response that he didn't create" do
          before(:each) do
            public_survey = FactoryGirl.create :survey, :public => true
            @response = Response.create(:survey => public_survey)            
            @response.session_token = "fooabc"
            @response.save
          end

          let!(:user_info) { user_info }

          it { should_not be_able_to :manage, @response }
        end
      end
    end
  end
end

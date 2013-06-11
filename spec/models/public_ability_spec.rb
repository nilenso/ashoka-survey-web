require "cancan/matchers"

describe "Abilities" do
  subject { ability }

  describe "public responses" do
    base_user_info =  {
      :name => "John",
      :email => "john@gmail.com",
      :org_id => 5,
      :user_id => 6,
      :session_token => "foo"
    }
    let(:ability){ PublicAbility.new(base_user_info) }


    roles =  %w(viewer field_agent supervisor designer manager cso_admin super_admin)
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

    context "a non-logged-in user" do
      let(:public_survey) { FactoryGirl.create :survey, :public => true  }
      let(:user_info) { { :session_token => "foo" } }
      let(:response) { Response.create(:survey => public_survey) }

      context "can manage a response that he created" do
        before(:each) do
          response.session_token = "foo"
          response.save
        end

        it { should be_able_to :manage, response }
        it { should_not be_able_to :destroy, Response }
        it { should_not be_able_to :read, Response }
      end

      context "cannot manage a response that he didn't create" do
        before(:each) do
          response.session_token = "fooabc"
          response.save
        end

        it { should_not be_able_to :manage, response }
      end
    end
  end
end

require 'cancan/matchers'

describe SuperAdminAbility do
  subject { ability }
  let(:user_info) {
    {
        :name => 'John',
        :email => 'john@gmail.com',
        :org_id => 5,
        :user_id => 6,
        :session_token => 'rdsfgasidufyas',
        :role => 'super_admin'
    }
  }
  let(:ability){ SuperAdminAbility.new(user_info) }

  it { should be_able_to :manage, Survey }
  it { should be_able_to :manage, :dashboard }
  it { should_not be_able_to :create, Survey }
  it { should_not be_able_to :create, Response }
  it { should be_able_to :manage, Response }
  it { should be_able_to :destroy, :organization }
end


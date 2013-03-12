require 'cancan/matchers'

describe AdminAbility do
  subject { ability }
  let(:user_info) {
    {
        :name => 'John',
        :email => 'john@gmail.com',
        :org_id => 5,
        :user_id => 6,
        :session_token => 'rdsfgasidufyas',
        :role => 'admin'
    }
  }
  let(:ability){ AdminAbility.new(user_info) }
end
      
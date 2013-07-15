require 'spec_helper'

describe UsersDecorator do
  it 'should find all the users by the id' do
    user = FactoryGirl.build(:user)
    user2 = FactoryGirl.build(:user)
    users = UsersDecorator.new([user, user2])
    users.find_by_id(user.id).should == user
  end
end
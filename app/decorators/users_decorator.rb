class UsersDecorator
  def initialize(users)
    @users = users
  end

  def find_by_id(user_id)
    @users.find { |user| user.id == user_id }
  end
end

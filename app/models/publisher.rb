class Publisher
  include ActiveModel::Validations

  validate :users_should_exist
  attr_reader :users, :survey, :client

  def initialize(survey, users, client)
    @survey = survey
    @users = users
    @client = client
  end

  def publish
    survey.publish_to_users(users)
  end

  private

  def users_should_exist
    errors.add(:users, "Users are not valid") unless User.exists?(client, users)
  end
end

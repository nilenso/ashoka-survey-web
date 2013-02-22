class Publisher
  include ActiveModel::Validations

  validate :users_should_exist, :unless => :public?
  validate :organizations_should_exist, :unless => :public?
  validates :expiry_date, :date => { :after => Proc.new { Date.current }}
  attr_reader :users, :survey, :client, :expiry_date, :organizations

  def initialize(survey, client, params)
    @survey = survey
    @organizations = Sanitizer.clean_params(params[:participating_organization_ids])
    @users = Sanitizer.clean_params(params[:user_ids])
    @client = client
    @public = params[:public] 
    @expiry_date = params[:expiry_date]
  end

  def publish
    return unless valid?
    survey.publish_to_users(users)
    survey.share_with_organizations(organizations)
    survey.publicize if public?
    survey.update_attributes(:expiry_date => expiry_date)
  end

  def unpublish_users
    survey.unpublish_users(users)
  end

  private

  def expiry_date
    Date.parse(@expiry_date)
  end

  def public?
    @public == '1' || survey.public?
  end

  def users_should_exist
    errors.add(:users, "Users are not valid") unless User.exists?(client, users)
  end

  def organizations_should_exist
    errors.add(:organizations, "Organizations are not valid") unless Organization.exists?(client, organizations)
  end
end

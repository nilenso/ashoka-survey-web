class Publisher
  include ActiveModel::Validations

  validate :users_should_exist, :unless => :public?
  validate :organizations_should_exist, :unless => :public?
  validates :expiry_date, :date => { :after => Proc.new { Date.today }}
  attr_reader :users, :survey, :client, :expiry_date, :organizations

  def initialize(survey, client, params)
    params ||= {}
    @survey = survey
    @organizations = Sanitizer.clean_params(params[:participating_organization_ids])
    @users = Sanitizer.clean_params(params[:user_ids])
    @client = client
    @public = params[:public]
    @expiry_date = params[:expiry_date]
    @thank_you_message = params[:thank_you_message]
  end

  def publish(options={})
    return unless valid?
    publish_to_users
    survey.publish
    survey.share_with_organizations(organizations) if survey.organization_id == options[:organization_id]
    if public?
      survey.publicize
      survey.thank_you_message = @thank_you_message
    end
    survey.update_attributes(:expiry_date => expiry_date)
  end

  def unpublish_users
    if survey.finalized?
      users.each { |user_id|  survey.survey_users.find_by_user_id(user_id).destroy }
    end
  end

  private

  def publish_to_users
    if survey.finalized?
      users.each { |user_id| survey.survey_users.create(:user_id => user_id) }
    end
  end


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

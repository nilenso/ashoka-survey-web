# Collection of questions

class Survey < ActiveRecord::Base
  attr_accessible :name, :expiry_date, :description, :questions_attributes, :finalized, :public
  validates_presence_of :name
  validates_presence_of :expiry_date
  validate :expiry_date_should_be_valid
  validate :expiry_date_should_not_be_in_past
  validate :expiry_date_should_not_be_older
  validate :description_should_be_short
  has_many :questions, :dependent => :destroy
  has_many :responses, :dependent => :destroy
  accepts_nested_attributes_for :questions
  belongs_to :organization
  has_many :survey_users, :dependent => :destroy
  has_many :participating_organizations, :dependent => :destroy
  has_many :categories, :dependent => :destroy
  validates_uniqueness_of :auth_key, :allow_nil => true
  scope :finalized, where(:finalized => true)
  scope :not_expired, where('expiry_date > ?', Date.today)
  scope :with_questions, joins(:questions)
  scope :drafts, where(:finalized => false)
  default_scope :order => 'published_on DESC NULLS LAST, created_at DESC'
  before_save :generate_auth_key, :if => :public?

  def finalize
    self.finalized = true
    self.save
  end

  def user_ids
    self.survey_users.map(&:user_id)
  end

  def users_for_organization(access_token, organization_id)
    users = {}
    field_agents = Organization.field_agents(access_token, organization_id)
    users[:published], users[:unpublished] = field_agents.partition do |field_agent|
      user_ids.include?(field_agent.id)
    end
    users
  end

  def partitioned_organizations(access_token)
    organizations = Organization.all(access_token, :except => organization_id)
    partitioned_organizations = {}
    partitioned_organizations[:participating], partitioned_organizations[:not_participating] = organizations.partition do |organization|
      participating_organization_ids.include? organization.id
    end
    partitioned_organizations
  end

  def expired?
    expiry_date < Date.today
  end

  def duplicate(options = {})
    survey = self.dup
    survey.finalized = false
    survey.name = "#{name}  #{I18n.t('activerecord.attributes.survey.copied')}"
    survey.organization_id = options[:organization_id] if options[:organization_id]
    survey.save(:validate => false)
    survey.questions << first_level_questions.map { |question| question.duplicate(survey.id) }
    survey
  end

  def publish_to_users(users)
    users.each { |user_id| self.survey_users.create(:user_id => user_id) } if finalized?
    set_published_on
  end

  def share_with_organizations(organizations)
    organizations.each do |organization_id|
      self.participating_organizations.create(:organization_id => organization_id)
    end if finalized?
    set_published_on
  end

  def published?
    !participating_organizations.empty? || !survey_users.empty?
  end

  def participating_organization_ids
    self.participating_organizations.map(&:organization_id)
  end

  def first_level_questions
    questions.where(:parent_id => nil, :category_id => nil)
  end

  def first_level_categories
    categories.where(:category_id => nil, :parent_id => nil)
  end

  def first_level_elements
    (first_level_questions + first_level_categories).sort_by(&:order_number)
  end

  def question_ids_in_order
    first_level_elements.map(&:with_sub_questions_in_order).flatten.map(&:id)
  end

  def questions_with_report_data
    questions.reject { |question| question.report_data.blank? }
  end

  def complete_responses_count
    responses.where(:status => 'complete').count
  end

  def incomplete_responses_count
    responses.where(:status => 'incomplete').count
  end

  def publicize
    self.public = true
    set_published_on
  end

  private

  def generate_auth_key
    self.auth_key = SecureRandom.urlsafe_base64
  end

  def expiry_date_should_not_be_in_past
    if !expiry_date.blank? and expiry_date < Date.current
      errors.add(:expiry_date, I18n.t('surveys.validations.cant_be_in_past'))
    end
  end

  def description_should_be_short
    if description && description.length > 250
      errors.add(:description, I18n.t('surveys.validations.too_long'))
    end
  end

  def expiry_date_should_be_valid
    errors.add(:expiry_date, I18n.t('surveys.validations.invalid')) if expiry_date.nil?
  end

  def expiry_date_should_not_be_older
    if expiry_date_changed? && !expiry_date_change.any?(&:nil?)
      errors.add(:expiry_date, I18n.t('surveys.validations.older_than_existing')) if expiry_date_change[1]  < expiry_date_change[0]
    end
  end

  def set_published_on
    if finalized
      self.published_on ||= Date.today
      self.save
    end
  end
end

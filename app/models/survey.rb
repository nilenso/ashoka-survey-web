# Collection of questions

class Survey < ActiveRecord::Base
  attr_accessible :name, :expiry_date, :description, :questions_attributes, :finalized, :public
  validates_presence_of :name
  validates_presence_of :expiry_date
  validates :expiry_date, :date => { :after => Proc.new { Date.today }}
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
  scope :active, lambda { where('finalized = ? AND expiry_date > ? AND archived = ?', true, Date.today, false) }
  scope :none, limit(0)
  scope :not_expired, lambda { where('expiry_date > ?', Date.today) }
  scope :expired, lambda { where('expiry_date < ?', Date.today) }
  scope :with_questions, joins(:questions)
  scope :drafts, where(:finalized => false)
  scope :archived, where(:archived => true)
  default_scope :order => 'published_on DESC NULLS LAST, created_at DESC'
  before_save :generate_auth_key, :if => :public?

  def finalize
    self.finalized = true
    self.save
  end

  def archive
    self.archived = true
    self.name = "#{name} #{I18n.t('activerecord.attributes.survey.archive')}"
    save
  end

  def user_ids
    self.survey_users.map(&:user_id)
  end

  def users_for_organization(access_token, organization_id)
    users = {}
    publishable_users = Organization.publishable_users(access_token, organization_id)
    users[:published], users[:unpublished] = publishable_users.partition do |publishable_user|
      user_ids.include?(publishable_user.id)
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
    survey.public = false
    survey.auth_key = nil
    survey.published_on = nil
    survey.save(:validate => false)
    survey.questions << first_level_questions.map { |question| question.duplicate(survey.id) }
    survey.categories << first_level_categories.map { |category| category.duplicate(survey.id) }
    survey
  end

  def share_with_organizations(organizations)
    organizations.each do |organization_id|
      participating_organizations.create(:organization_id => organization_id)
    end if finalized?
    set_published_on
  end

  def publish
    set_published_on
  end

  def published?
    !participating_organizations.empty? || !survey_users.empty? || public?
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

  def first_level_categories_with_questions
    first_level_categories.includes([:questions, :categories]).select { |x| x.has_questions? }
  end

  def first_level_elements
    (first_level_questions + first_level_categories_with_questions).sort_by(&:order_number)
  end

  def elements_in_order_as_json
    first_level_elements.map(&:as_json_with_elements_in_order)
  end

  def questions_for_reports
    questions.joins(:answers => :response).where("responses.status = 'complete' AND responses.state = 'clean' AND ((answers.content  <> '' AND answers.content IS NOT NULL) OR
                                                questions.type = 'MultiChoiceQuestion')").uniq
  end

  def complete_responses_count(current_ability)
    responses.accessible_by(current_ability).where(:status => 'complete', :blank => false).count
  end

  def incomplete_responses_count(current_ability)
    responses.accessible_by(current_ability).where(:status => 'incomplete', :blank => false).count
  end

  def publicize
    self.public = true
    set_published_on
  end

  def identifier_questions
    identifier_questions = questions.where(:identifier => :true)
    identifier_questions.blank? ? first_level_questions.limit(5).to_a : identifier_questions
  end

  def filename_for_excel
    "#{name.gsub(/\W/, "")} (#{id}) - #{Time.now.strftime("%Y-%m-%d %I.%M.%S%P")}.xlsx"
  end

  private

  def generate_auth_key
    self.auth_key = SecureRandom.urlsafe_base64
  end

  def description_should_be_short
    if description && description.length > 250
      errors.add(:description, I18n.t('surveys.validations.too_long'))
    end
  end

  def set_published_on
    if finalized
      self.published_on ||= Date.today
      self.save
    end
  end
end

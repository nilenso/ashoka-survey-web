# Collection of questions

class Survey < ActiveRecord::Base
  attr_accessible :name, :expiry_date, :description, :questions_attributes, :published
  validates_presence_of :name
  validate :expiry_date_should_not_be_in_past
  has_many :questions, :dependent => :destroy
  has_many :responses, :dependent => :destroy
  validate :expiry_date_shoud_be_valid
  accepts_nested_attributes_for :questions
  belongs_to :organization
  has_many :survey_users, :dependent => :destroy
  has_many :participating_organizations, :dependent => :destroy

  def publish
    self.published = true
    self.save
  end

  def user_ids
    self.survey_users.map(&:user_id)
  end

  def share_with_users(users)
    users.each { |user_id| self.survey_users.create(:user_id => user_id) }
  end

  def share_with_organizations(organizations)
    organizations.each do |organization_id| 
      self.participating_organizations.create(:organization_id => organization_id) 
    end
  end

  def participating_organization_ids
    self.participating_organizations.map(&:organization_id)
  end

  private

  def expiry_date_should_not_be_in_past
    if !expiry_date.blank? and expiry_date < Date.current
      errors.add(:expiry_date, "can't be in the past")
    end
  end

  def expiry_date_shoud_be_valid
    errors.add(:expiry_date, "is not valid") if expiry_date.nil?
  end
end

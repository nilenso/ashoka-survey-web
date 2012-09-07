# A specificaton for a piece of info that the survey designer wants to collect.

class Question < ActiveRecord::Base
  belongs_to :survey
  attr_accessible :content, :mandatory, :max_length, :image, :type, :survey_id, :max_value, :min_value, :order_number
  validates_presence_of :content
  has_many :answers, :dependent => :destroy
  has_many :options, :dependent => :destroy
  has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x100>" }
  accepts_nested_attributes_for :options
  validate :min_value_less_than_max_value
  validates_uniqueness_of :order_number, :scope => :survey_id
  default_scope :order => 'order_number'
  private

  def min_value_less_than_max_value
    if min_value && max_value && (min_value > max_value)
      errors.add(:min_value, I18n.t('questions.validations.min_value_higher')) 
    end
  end
end
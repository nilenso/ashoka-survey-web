# A specificaton for a piece of info that the survey designer wants to collect.

class Question < ActiveRecord::Base
  acts_as_nested_set

  belongs_to :survey
  attr_accessible :content, :mandatory, :image, :type, :survey_id, :order_number, :parent_id
  validates_presence_of :content
  has_many :answers, :dependent => :destroy
  has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x100>" }
  validates_uniqueness_of :order_number, :scope => :survey_id

  default_scope :order => 'order_number'

  def image_url
    return image.url(:thumb) if image.exists?
    nil
  end

  def as_json(options={})
    super(options.merge({:except => [:lft, :rgt]}))
  end

  def to_json(options={})
    super(options.merge({:except => [:lft, :rgt]}))
  end

  def self.new_question_by_type(type, question_params)
    question_class = type.classify.constantize
    question_class.new(question_params)
  end
end
# A specificaton for a piece of info that the survey designer wants to collect.

class Question < ActiveRecord::Base
  belongs_to :parent, :class_name => Option
  belongs_to :survey
  attr_accessible :content, :mandatory, :image, :type, :survey_id, :order_number, :parent_id, :identifier
  validates_presence_of :content
  has_many :answers, :dependent => :destroy
  has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x100>" }
  validates_uniqueness_of :order_number, :scope => [:survey_id, :parent_id], :allow_nil => true

  default_scope :order => 'order_number'
  delegate :question, :to => :parent, :prefix => true

  def image_url
    return image.url(:thumb) if image.exists?
    nil
  end

  def image_in_base64
    if image?
      Base64.encode64(File.read(image.path(:thumb)))
    end
  end

  def duplicate(survey_id)
    question = self.dup
    question.survey_id = survey_id
    question.options << options.map { |option| option.duplicate(survey_id) } if self.respond_to? :options
    question.save(:validate => false)
    question
  end

  def with_sub_questions_in_order
    [self]
  end

  def json(opts={})
    return as_json(opts).merge({:options => options.map(&:as_json)}) if respond_to? :options
    return as_json(opts)
  end

  def self.new_question_by_type(type, question_params)
    question_class = type.classify.constantize
    question_class.new(question_params)
  end

  def first_level?
    self.parent == nil
  end

  def report_data
    []
  end

  def nesting_level
    return 1 unless parent
    return parent_question.nesting_level + 1
  end
end

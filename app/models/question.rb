# A specificaton for a piece of info that the survey designer wants to collect.

class Question < ActiveRecord::Base
  belongs_to :parent, :class_name => Option
  belongs_to :category
  belongs_to :survey
  attr_accessible :content, :mandatory, :image, :type, :survey_id, :order_number, :parent_id, :identifier, :category_id
  validates_presence_of :content
  has_many :answers, :dependent => :destroy
  mount_uploader :image, ImageUploader
  store_in_background  :image
  validates_uniqueness_of :order_number, :scope => [:survey_id, :parent_id, :category_id], :allow_nil => true

  default_scope :order => 'order_number'
  delegate :question, :to => :parent, :prefix => true

  def image_url(format=nil)
    return "/#{image.cache_dir}/#{image_tmp}" if image_tmp
    return image.url(format) if image.file
  end

  def image_in_base64
    file =  File.read("#{image.root}/#{image.cache_dir}/#{image_tmp}") if image_tmp
    file = image.thumb.file.read if image.thumb.file.try(:exists?)
    return Base64.encode64(file) if file
  end

  def create_blank_answers(params={})
    answer = Answer.new(:question_id => id, :response_id => params[:response_id], :record_id => params[:record_id])
    answer.save(:validate => false)
  end

  def duplicate(survey_id)
    question = self.dup
    question.survey_id = survey_id
    question.options << options.map { |option| option.duplicate(survey_id) } if self.respond_to? :options
    question.save(:validate => false)
    question
  end

  def copy_with_order
    duplicate_question = duplicate(survey_id)
    duplicate_question.order_number += 1
    return false unless duplicate_question.save
    true
  end

  def as_json_with_elements_in_order
    self.as_json(:methods => 'type')
  end

  def questions_in_order
    [self]
  end

  def options
    []
  end

  def json(opts={})
    return as_json(opts).merge({:options => options.map(&:as_json)}) if respond_to? :options
    return as_json(opts)
  end

  def self.new_question_by_type(type, question_params)
    question_class = type.classify.constantize
    question_class.new(question_params)
  end

  def sorted_answers_for_response(response_id, record_id=nil)
    [answers.find_by_response_id_and_record_id(response_id, record_id)].compact.flatten
  end

  def first_level?
    self.parent == nil && self.category == nil
  end

  def report_data
    Answer.unscoped.joins(:response).where("answers.question_id = ? 
                                 AND responses.status = 'complete'
                                 AND responses.state = 'clean'", id)
  end

  def nesting_level
    return parent_question.nesting_level + 1 if parent && parent_question
    return category.nesting_level + 1 if category
    return 1
  end

  def index_of_parent_option
    parent_options = parent_question.options
    parent_options.index(parent)
  end

  def has_multi_record_ancestor?
    category.try(:is_a?, MultiRecordCategory) || category.try(:has_multi_record_ancestor?) || parent.try(:has_multi_record_ancestor?)
  end

  def reporter
    QuestionReporter.decorate(self)
  end

  protected

  def has_multi_record_ancestor
    has_multi_record_ancestor?
  end
end

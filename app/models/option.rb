class Option < ActiveRecord::Base
  belongs_to :question
  has_many :questions, :foreign_key => :parent_id, :dependent => :destroy
  has_many :categories, :foreign_key => :parent_id, :dependent => :destroy
  attr_accessible :content, :question_id, :order_number
  validates_uniqueness_of :order_number, :scope => :question_id
  validates_presence_of :content, :question_id
  delegate :survey, :to => :question, :prefix => false, :allow_nil => true
  delegate :marked_for_deletion?, :to => :survey, :prefix => true

  scope :finalized, where(:finalized => true)
  scope :ascending, :order => "order_number ASC"

  before_destroy do |option|
    return if option.survey_marked_for_deletion?
    !option.finalized?
  end

  def duplicate(survey_id)
    option = self.dup
    option.finalized = false
    option.questions << questions.map { |question| question.duplicate(survey_id) }
    option.categories << categories.map { |category| category.duplicate(survey_id) }
    option.save(:validate => false)
    option
  end

  def elements
    (questions + categories).sort_by(&:order_number)
  end

  def as_json(opts={})
    super(opts.merge({:methods => :has_multi_record_ancestor })).merge({:questions => questions.map { |question| question.json(:methods => :type) }})
  end

  def report_data(answers)
    answers.where(:content => content).count
  end

  def categories_with_questions
    categories.select { |x| x.has_questions? }
  end

  def has_multi_record_ancestor?
    question.try(:has_multi_record_ancestor?)
  end

  def as_json_with_elements_in_order
    json = { 'id' => id, 'content' => content, 'question_id' => question_id, 'order_number' => order_number}
    json['elements'] = elements.map(&:as_json_with_elements_in_order).flatten
    json
  end

  def ordered_question_tree
    elements.map(&:ordered_question_tree).flatten
  end

  def elements_with_questions
    (questions + categories_with_questions).sort_by(&:order_number)
  end

  def find_or_initialize_answers_for_response(response, options={})
    elements.map { |element| element.find_or_initialize_answers_for_response(response, options) }.flatten
  end

  protected

  def has_multi_record_ancestor
    has_multi_record_ancestor?
  end
end

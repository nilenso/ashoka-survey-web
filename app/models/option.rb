class Option < ActiveRecord::Base
  belongs_to :question
  has_many :questions, :foreign_key => :parent_id, :dependent => :destroy
  has_many :categories, :foreign_key => :parent_id, :dependent => :destroy
  attr_accessible :content, :question_id, :order_number
  validates_uniqueness_of :order_number, :scope => :question_id
  validates_presence_of :content, :question_id
  default_scope :order => 'order_number'
  delegate :survey, :to => :question, :prefix => false, :allow_nil => true

  def duplicate(survey_id)
    option = self.dup
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

  def elements_with_questions
    (questions + categories_with_questions).sort_by(&:order_number)
  end

  protected

  def has_multi_record_ancestor
    has_multi_record_ancestor?
  end
end

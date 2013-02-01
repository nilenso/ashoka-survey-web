class Record < ActiveRecord::Base
  belongs_to :category
  belongs_to :response
  has_many :answers, :dependent => :destroy
  attr_accessible :category_id, :response_id

  validates_presence_of :response_id
  validates_presence_of :category_id

  after_create :create_answers_for_category_questions

  def create_answers_for_category_questions
    if category
      category.questions.each do |question|
        answers << Answer.create(:question_id => question.id, :response_id => response_id)
      end
    end
  end
end

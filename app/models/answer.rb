# A piece of information for a question

class Answer < ActiveRecord::Base
  belongs_to :question
  attr_accessible :content, :question_id
  validate :mandatory_questions_should_be_answered

  private

  def mandatory_questions_should_be_answered
    if content.blank? && question.mandatory
      errors.add(:content, 'This question is mandatory.')
    end
  end
end

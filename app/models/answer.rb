# A piece of information for a question

class Answer < ActiveRecord::Base
  belongs_to :question
  attr_accessible :content, :question_id, :choices_attributes
  validate :mandatory_questions_should_be_answered
  validate :content_should_not_exceed_max_length
  validate :content_should_be_in_range
  has_many :choices, :dependent => :destroy
  accepts_nested_attributes_for :choices

  private

  def mandatory_questions_should_be_answered
    if content.blank? && question.mandatory
      errors.add(:content, I18n.t('answers.validations.mandatory_question'))
    end
  end

  def content_should_not_exceed_max_length
  	if question.max_length && content.length > question.max_length
  		errors.add(:content, I18n.t("answers.validations.max_length"))
  	end
  end
  def content_should_be_in_range
    min_value, max_value = question.min_value, question.max_value
    if min_value && max_value && (min_value..max_value).exclude?(content.to_i)
      errors.add(:content, I18n.t("answers.validations.exceeded_range"))
    end
  end
end

# A piece of information for a question

class Answer < ActiveRecord::Base
  belongs_to :question
  attr_accessible :content, :question_id
  validate :mandatory_questions_should_be_answered
  validate :content_should_not_exceed_max_length
  validate :content_should_be_in_range
  has_many :choices, :dependent => :destroy
  validate :date_should_be_valid

  after_create :create_multiple_choices, :if => lambda { question.is_a?(MultiChoiceQuestion) }

  private

  def create_multiple_choices
    choice_array = content.delete_if { |choice| choice.blank? }
    self.content = 'MultipleChoice'
    choice_array.each { |choice| choices << Choice.new(:content => choice) }
    save!
  end

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

  def date_should_be_valid
    if question.type == "DateQuestion"
      unless content =~ /\A\d{4}\/(?:0?[1-9]|1[0-2])\/(?:0?[1-9]|[1-2]\d|3[01])\Z/
        errors.add(:content, I18n.t("answers.validations.invalid_date"))
      end
    end
  end
end

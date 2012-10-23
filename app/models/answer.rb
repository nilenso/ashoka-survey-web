# A piece of information for a question

class Answer < ActiveRecord::Base
  belongs_to :question
  belongs_to :response
  attr_accessible :content, :question_id, :option_ids
  validate :mandatory_questions_should_be_answered, :if => :response_complete?
  validate :content_should_not_exceed_max_length
  validate :content_should_be_in_range
  has_many :choices, :dependent => :destroy
  validate :date_should_be_valid
  attr_accessible :photo
  has_attached_file :photo, :styles => { :medium => "300x300>"}
  validates_attachment_content_type :photo, :content_type=>['image/jpeg', 'image/png']
  validate :maximum_photo_size
  validates_numericality_of :content, :if => Proc.new {|answer| (answer.content.present?) && (answer.question.type == 'NumericQuestion') }

  def option_ids
    self.choices.collect(&:option_id)
  end

  def option_ids=(ids)
    ids.delete_if(&:blank?)
    ids.each { |option_id| choices << Choice.new(:option_id => option_id) }
  end

  def text_type?
    question.type != "MultiChoiceQuestion" && question.type != "PhotoQuestion"
  end

  def question_content
    question.content
  end

  private

  def response_complete?
    response.complete?
  end

  def maximum_photo_size
    if question.type == "PhotoQuestion"
      if question.max_length && question.max_length.megabytes < photo_file_size
        errors.add(:photo, I18n.t('answers.validations.exceeds_maximum_size'))
      elsif photo_file_size && 5.megabytes < photo_file_size
        errors.add(:photo, I18n.t('answers.validations.exceeds_maximum_size'))
      end
    end
  end


  def mandatory_questions_should_be_answered
    if question.mandatory && has_not_been_answered?
      errors.add(:content, I18n.t('answers.validations.mandatory_question'))
    end
  end

  def content_should_not_exceed_max_length
    if question.type != "PhotoQuestion" && question.max_length && content.length > question.max_length
      errors.add(:content, I18n.t("answers.validations.max_length"))
    elsif question.type == "RatingQuestion" && question.max_length && content.to_i > question.max_length
      errors.add(:content, I18n.t("answers.validations.max_length"))
    end
  end

  def content_should_be_in_range
    unless has_not_been_answered?
      min_value, max_value = question.min_value, question.max_value
      if min_value && content.to_i < min_value
        errors.add(:content, I18n.t("answers.validations.exceeded_lower_limit"))
      elsif max_value && content.to_i > max_value
        errors.add(:content, I18n.t("answers.validations.exceeded_higher_limit"))
      end
    end
  end

  def date_should_be_valid
    unless has_not_been_answered?
      if question.type == "DateQuestion"
        unless content =~ /\A\d{4}\/(?:0?[1-9]|1[0-2])\/(?:0?[1-9]|[1-2]\d|3[01])\Z/
          errors.add(:content, I18n.t("answers.validations.invalid_date"))
        end
      end
    end
  end

  def has_not_been_answered?
    if question.is_a?(MultiChoiceQuestion)
      choices.empty?
    else
      content.blank?
    end
  end
end

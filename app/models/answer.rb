# A piece of information for a question

class Answer < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  belongs_to :question
  belongs_to :response
  attr_accessible :content, :question_id, :option_ids, :updated_at
  validate :mandatory_questions_should_be_answered, :if => :response_validating?
  validate :content_should_not_exceed_max_length
  validate :content_should_be_in_range
  validates_uniqueness_of :question_id, :scope => [:response_id]
  has_many :choices, :dependent => :destroy
  validate :date_should_be_valid
  attr_accessible :photo
  has_attached_file :photo, :styles => { :medium => "300x300>", :thumb => "100x100>"}
  validates_attachment_content_type :photo, :content_type=>['image/jpeg', 'image/png']
  validate :maximum_photo_size
  validates_numericality_of :content, :if => Proc.new {|answer| (answer.content.present?) && (answer.question.type == 'NumericQuestion') }
  after_save :touch_multi_choice_answer

  default_scope includes('question').order('questions.order_number')
  delegate :content, :to => :question, :prefix => true
  delegate :validating?, :to => :response, :prefix => true
  delegate :identifier?, :to => :question

  def option_ids
    self.choices.collect(&:option_id)
  end

  def option_ids=(ids)
    ids.delete_if(&:blank?)
    choices.destroy_all
    ids.each { |option_id| choices << Choice.new(:option_id => option_id) }
  end

  def content
    if question.type == "MultiChoiceQuestion"
      choices.map(&:content).join(", ")
    else
      self[:content]
    end
  end

  def content_for_excel(server_url='')
    # TODO: Refactor these `if`s when implementing STI for the Answer model
    return choices.map(&:content).join(", ") if question.type == 'MultiChoiceQuestion'
    return (server_url + photo.url) if question.type == 'PhotoQuestion'
    return content
  end

  def image?
    question.type == "PhotoQuestion"
  end

  def thumb_url
    photo.url(:thumb) if photo?
  end

  private

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
      if question.is_a?(PhotoQuestion)
        errors.add(:photo, I18n.t('answers.validations.mandatory_question'))
      else
        errors.add(:content, I18n.t('answers.validations.mandatory_question'))
      end
    end
  end

  def content_should_not_exceed_max_length
    if question.type != "PhotoQuestion" && question.max_length && content && content.length > question.max_length
      errors.add(:content, I18n.t("answers.validations.max_length"))
    elsif question.type == "RatingQuestion" && question.max_length && content && content.to_i > question.max_length
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

  # Editing choices doesn't change the `updated_at` for the answer by default.
  def touch_multi_choice_answer
    touch if question.type == "MultiChoiceQuestion"
  end
end

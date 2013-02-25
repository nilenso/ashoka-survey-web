# A piece of information for a question

class Answer < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  belongs_to :question
  belongs_to :response
  belongs_to :record
  attr_accessible :content, :question_id, :option_ids, :updated_at, :response_id, :record_id
  validate :mandatory_questions_should_be_answered, :if => :response_validating?
  with_options :if => :has_been_answered? do |condition|
    condition.validate :date_should_be_valid
    condition.validate :content_should_be_in_range
  end
  validate :content_should_not_exceed_max_length, :if => :max_length_and_content_present?
  validates_uniqueness_of :question_id, :scope => [:response_id, :record_id]
  has_many :choices, :dependent => :destroy
  has_many :photos, :dependent => :destroy

  attr_accessible :photo
  mount_uploader :photo, ImageUploader
  store_in_background :photo
  validate :maximum_photo_size, :if => :content_present?
  validates_numericality_of :content, :if => :numeric_question?
  after_save :touch_multi_choice_answer

  default_scope includes('question').order('questions.order_number')
  delegate :content, :to => :question, :prefix => true
  delegate :validating?, :to => :response, :prefix => true
  delegate :type, :to => :question, :prefix => true
  delegate :identifier?, :to => :question
  delegate :first_level?, :to => :question
  delegate :order_number, :to => :question, :prefix => true

  scope :complete, joins(:response).where("responses.status = 'complete'")

  def option_ids
    self.choices.collect(&:option_id)
  end

  def option_ids=(ids)
    return unless ids
    ids.delete_if(&:blank?)
    choices.destroy_all
    choices << ids.collect { |option_id| Choice.new(:option_id => option_id) }
  end

  def content
    if question_type == "MultiChoiceQuestion"
      choices.map(&:content).join(", ")
    else
      self[:content]
    end
  end

  def content_for_excel(server_url='')
    # TODO: Refactor these `if`s when implementing STI for the Answer model
    return photo_url(:server_url => server_url) if question.type == 'PhotoQuestion'
    return content
  end

  def image?
    question_type == "PhotoQuestion"
  end

  def clear_content
    update_attribute :content, nil
  end

  def photo_url(opts={})
    return opts[:server_url].to_s + "/#{photo.cache_dir}/#{photo_tmp}" if photo_tmp
    return photo.url(opts[:format]) if photo.file
    return ""
  end

  def photo_in_base64
    file = File.read("#{photo.root}/#{photo.cache_dir}/#{photo_tmp}") if photo_tmp
    file = photo.thumb.file.read if photo.thumb.file.try(:exists?)
    return Base64.encode64(file) if file
  end


  def has_not_been_answered?
    if question.is_a?(MultiChoiceQuestion)
      choices.empty?
    else
      content.blank?
    end
  end

  def has_been_answered?
    !has_not_been_answered?
  end

  private

  def maximum_photo_size
    return unless question_type == "PhotoQuestion"
    if question.max_length && question.max_length.megabytes < photo.size
      errors.add(:photo, I18n.t('answers.validations.exceeds_maximum_size'))
    elsif 5.megabytes < photo.size
      errors.add(:photo, I18n.t('answers.validations.exceeds_maximum_size'))
    end
  end

  def max_length_and_content_present?
    content_present? && question.max_length
  end

  def content_present?
    content.present? || photo.present?
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

  def photo_or_numeric_type_question
    question_type == "PhotoQuestion" || question_type == "NumericQuestion"
  end

  def content_max_legnth_validation
    if question_type == "RatingQuestion"
      content.to_i > question.max_length
    else
      content.length > question.max_length
    end
  end

  def content_should_not_exceed_max_length
    return if photo_or_numeric_type_question
    if content_max_legnth_validation
      errors.add(:content, I18n.t("answers.validations.max_length"))
    end
  end

  def content_should_be_in_range
    min_value, max_value = question.min_value, question.max_value
    if min_value && content.to_i < min_value
      errors.add(:content, I18n.t("answers.validations.exceeded_lower_limit"))
    elsif max_value && content.to_i > max_value
      errors.add(:content, I18n.t("answers.validations.exceeded_higher_limit"))
    end
  end

  def date_should_be_valid
    if question_type == "DateQuestion"
      unless content =~ /\A\d{4}\/(?:0?[1-9]|1[0-2])\/(?:0?[1-9]|[1-2]\d|3[01])\Z/
        errors.add(:content, I18n.t("answers.validations.invalid_date"))
      end
    end
  end

  def numeric_question?
    content.present? && question_type == "NumericQuestion"
  end

  # Editing choices doesn't change the `updated_at` for the answer by default.
  def touch_multi_choice_answer
    touch if question_type == "MultiChoiceQuestion"
  end
end

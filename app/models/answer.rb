class Answer < ActiveRecord::Base
  belongs_to :question
  belongs_to :response
  belongs_to :record
  has_many :choices, :dependent => :destroy

  attr_accessible :content, :question_id, :option_ids, :updated_at, :response_id, :record_id, :photo

  mount_uploader :photo, ImageUploader
  store_in_background :photo, AnswerPhotoWorker

  with_options :if => :has_been_answered? do |condition|
    condition.validate :date_should_be_valid
    condition.validate :content_should_be_in_range
  end
  validate :mandatory_questions_should_be_answered, :if => :response_complete?
  validate :content_should_not_exceed_max_length, :if => :max_length_and_content_present?
  validate :question_should_be_finalized
  validate :maximum_photo_size, :if => :content_present?
  validates_uniqueness_of :question_id, :scope => [:response_id, :record_id]
  validates_numericality_of :content, :if => :numeric_question?

  after_save :touch_multi_choice_answer

  delegate :content, :to => :question, :prefix => true
  delegate :complete?, :to => :response, :prefix => true
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
    if question.type == 'PhotoQuestion'
      photo_url(:server_url => server_url)
    else
      content
    end
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
    file = photo.file.read if photo.file.try(:exists?)
    return Base64.encode64(file) if file
  end


  def has_not_been_answered?
    if question.is_a?(MultiChoiceQuestion)
      choices.empty?
    elsif question.is_a?(PhotoQuestion)
      photo_url.blank?
    else
      content.blank?
    end
  end

  def has_been_answered?
    !has_not_been_answered?
  end

  def update_photo_size!
    if photo.present?
      update_column(:photo_file_size, photo.file.size + photo.thumb.file.size + photo.medium.file.size)
    else
      update_column(:photo_file_size, nil)
    end
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
    if question.mandatory? && has_not_been_answered?
      if question.is_a?(PhotoQuestion)
        errors.add(:photo, I18n.t('answers.validations.mandatory_question'))
      elsif question.is_a?(MultiChoiceQuestion)
        errors.add(:option_ids, I18n.t('answers.validations.mandatory_question'))
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

  def question_should_be_finalized
    unless question.finalized?
      errors.add(:question_id, :should_be_finalized)
    end
  end
end

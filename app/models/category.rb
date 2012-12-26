class Category < ActiveRecord::Base
  belongs_to :parent, :class_name => Option
  belongs_to :category
  attr_accessible :content, :survey_id, :order_number, :category_id, :parent_id
  has_many :questions, :dependent => :destroy
  has_many :categories, :dependent => :destroy
  validates_presence_of :content
  belongs_to :survey

  delegate :question, :to => :parent, :prefix => true, :allow_nil => true

  def elements
    questions + categories
  end

  def with_sub_questions_in_order
    elements.map(&:with_sub_questions_in_order).flatten
  end

  def nesting_level
    return parent_question.nesting_level + 1 if parent
    return category.nesting_level + 1 if category
    return 1
  end

  def sub_question?
    parent || category.try(:sub_question?)
  end
end

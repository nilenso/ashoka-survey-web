class MultiRecordCategory < Category
  has_many :records, :foreign_key => :category_id
  validate :dont_allow_nested_multi_record, :if => :has_multi_record_ancestor?

  def records_for_response(response_id)
    records.where(:response_id => response_id)
  end

  def find_or_initialize_answers_for_response(response, options={})
    records.where(:response_id => response.id).map do |record|
      (questions + categories).map { |element| element.find_or_initialize_answers_for_response(response, :record_id => record.id) }
    end.flatten
  end

  protected

  def dont_allow_nested_multi_record
    errors.add(:base, "No nested multi-records allowed.")
  end
end

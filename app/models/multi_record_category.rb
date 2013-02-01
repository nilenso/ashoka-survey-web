class MultiRecordCategory < Category
  validate :dont_allow_nested_multi_record, :if => :has_multi_record_ancestor?

  def sorted_answers_for_response(response_id, record_id=nil)
    records.where(:response_id => response_id).map { |record| super(response_id, record.id) }.flatten
  end
  
  protected

  def dont_allow_nested_multi_record
    errors.add(:base, "No nested multi-records allowed.")
  end
end

class MultiRecordCategory < Category
  validate :dont_allow_nested_multi_record, :if => :has_multi_record_ancestor?
  
  protected

  def dont_allow_nested_multi_record
    errors.add(:base, "No nested multi-records allowed.")
  end
end

# A container for other questions

class MultiRecordQuestion < Question
  has_many :questions

  def as_json(opts={})
    super(opts.merge(:include => [{ :questions => { :methods => :type }}]))
  end
end

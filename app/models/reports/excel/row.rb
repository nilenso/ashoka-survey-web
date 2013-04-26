class Reports::Excel::Row
  attr_reader :elements

  def initialize(*args)
    @elements = args
  end

  def to_a
    @elements.dup
  end

  def <<(elements)
    @elements << elements
    @elements.flatten!
    self
  end
end

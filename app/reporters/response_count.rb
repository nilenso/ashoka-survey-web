class ResponseCount
  attr_reader :month
  attr_accessor :incompletes, :completes

  def initialize(month, incompletes=0, completes=0)
    @month = month
    @incompletes = incompletes
    @completes = completes
  end

  def merge(other)
    merged_count = ResponseCount.new(self.month, self.incompletes, self.completes)
    if other.present?
      merged_count.incompletes += other.incompletes
      merged_count.completes += other.completes
    end
    merged_count
  end
end
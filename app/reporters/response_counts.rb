require 'forwardable'

class ResponseCounts
  attr_reader :counts
  extend Forwardable

  def_delegators :@counts, :<<, :each

  def initialize(counts=[])
    @counts = counts
  end

  def merge(other)
    unique_months_between(other).inject(ResponseCounts.new) do |merged_counts, month|
      count = find_by_month(month)
      other_count = other.find_by_month(month)
      if count.present?
        merged_counts << count.merge(other_count)
      else
        merged_counts << other_count.merge(count)
      end
      merged_counts
    end
  end

  def each_in_reverse_chronological_order(&blk)
    @counts.sort_by { |count| Date.parse(count.month) }.reverse.each(&blk)
  end

  def find_by_month(month)
    @counts.find { |count| count.month == month }
  end

  def unique_months_between(other)
    (counts.map(&:month) + other.counts.map(&:month)).uniq
  end
end
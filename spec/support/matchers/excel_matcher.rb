RSpec::Matchers.define :have_header_cell do |cell_value|
  match do |ws|
    ws.rows[0].cells.map(&:value).include? cell_value
  end
end

RSpec::Matchers.define :have_cell do |expected|
  match do |ws|
    ws.rows[@index].cells.map(&:value).include? expected
  end

  chain :in_row do |index|
    @index = index
  end

  failure_message_for_should do |actual|
    "Expected #{actual} to include #{expected} at row #{@index}."
  end
end

RSpec::Matchers.define :have_cell_containing do |expected|
  match do |ws|
    ws.rows[@index].cells.map(&:value).any? do |cell_value|
      cell_value =~ /#{expected}/
    end
  end

  chain :in_row do |index|
    @index = index
  end

  failure_message_for_should do |actual|
    "Expected #{actual} to include a cell matching #{expected} at row #{@index}."
  end
end


RSpec::Matchers.define :have_header_cell do |cell_value|
  match do |ws|
    ws.rows[0].cells.map(&:value).include? cell_value
  end
end

RSpec::Matchers.define :have_cell do |cell_value|
  match do |ws|
    ws.rows[@index].cells.map(&:value).include? cell_value
  end

  chain :in_row do |index|
    @index = index
  end

  failure_message_for_should do |actual|
    "Expected #{actual} to include #{cell_value} at row #{@index}."
  end
end


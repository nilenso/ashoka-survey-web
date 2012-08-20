module ApplicationHelper
  def format_flash_message(message)
    message.is_a?(Array) ? message.join("\n") : message
  end
end

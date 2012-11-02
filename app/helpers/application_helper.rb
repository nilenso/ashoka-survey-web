module ApplicationHelper
  def format_flash_message(message)
    message.is_a?(Array) ? message.join("\n") : message
  end

  def server_url
    request.protocol + request.host_with_port
  end

  def icon_for(css_class, text)
    "<i class=#{css_class}></i>".html_safe + text
  end
end

module SurveyHelper
  def icon_for(css_class, text)
    "<i class=#{css_class}></i>".html_safe + text
  end
end

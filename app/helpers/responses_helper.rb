module ResponsesHelper

  def get_option_content_from_option_id(id)
    Option.find_by_id(id).try(:content)
  end
end

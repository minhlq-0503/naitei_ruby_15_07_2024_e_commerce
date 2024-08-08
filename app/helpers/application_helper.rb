module ApplicationHelper
  def full_title page_title = ""
    base_title = t "defaults.name"
    page_title.blank? ? base_title : "#{page_title} | #{base_title}"
  end

  def skip_header?
    action_name == "new"
  end

  def skip_container?
    action_name == "new"
  end
end

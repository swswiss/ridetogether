module ApplicationHelper
  def nav_item_class(path)
    active =
      current_page?(path) ||
      (path == new_group_path && controller_name == "groups" && action_name == "create")

    class_names("nav-item", active: active)
  end

  def nav_item_class_bottom(path)
    active =
      current_page?(path) ||
      (path == new_group_path && controller_name == "groups" && action_name == "create")

    class_names(active: active)
  end
end
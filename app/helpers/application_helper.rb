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

  def group_initials(name)
    name.to_s
        .split
        .reject(&:empty?)
        .first(3)
        .map { |word| word[0] }
        .join
        .upcase
  end

  def created_at_label(date)
    months = %w[ian feb mar apr mai iun iul aug sep oct nov dec]
  
    "creat în #{months[date.month - 1]} #{date.year}"
  end
end
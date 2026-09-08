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

  def din_created_at_label(date)
    months = %w[ian feb mar apr mai iun iul aug sep oct nov dec]
  
    "din #{months[date.month - 1]} #{date.year}"
  end

  ROMANIAN_DAYS = [
    "Duminică",
    "Luni",
    "Marți",
    "Miercuri",
    "Joi",
    "Vineri",
    "Sâmbătă"
  ].freeze

  ROMANIAN_MONTHS = [
    nil,
    "ianuarie",
    "februarie",
    "martie",
    "aprilie",
    "mai",
    "iunie",
    "iulie",
    "august",
    "septembrie",
    "octombrie",
    "noiembrie",
    "decembrie"
  ].freeze

  def event_date_time(event)
    date = event.date
    time = event.time

    "#{ROMANIAN_DAYS[date.wday]}, #{date.day} #{ROMANIAN_MONTHS[date.month]} · #{time.strftime("%H:%M")}"
  end

  def event_duration(event)
    minutes = event.estimated_duration_minutes

    return "-" if minutes.blank?

    hours = minutes / 60
    remaining_minutes = minutes % 60

    parts = []

    if hours.positive?
      parts << "#{hours} #{hours == 1 ? 'oră' : 'ore'}"
    end

    if remaining_minutes.positive?
      parts << "#{remaining_minutes} min"
    end

    parts.join(" și ")
  end
end
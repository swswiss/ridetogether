module ApplicationHelper
  
  def nav_item_class(controller, action: nil)
    active =
      controller_name == controller.to_s &&
      (action.nil? || action_name == action.to_s)

    class_names("nav-item", active: active)
  end
end

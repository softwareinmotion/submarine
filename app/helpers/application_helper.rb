module ApplicationHelper
  def controller_action_matcher(controller, action)
    lambda do
     controller == controller_name && action == action_name
    end
  end

  # wrapper for the rails l method to return an empty string for nil
  def to_local(date_or_nil)
    l(date_or_nil) unless date_or_nil.blank?
  end
end

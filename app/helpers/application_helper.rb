module ApplicationHelper
  def controller_action_matcher(controller, action)
    lambda do
     controller == controller_name && action == action_name
    end
  end
end

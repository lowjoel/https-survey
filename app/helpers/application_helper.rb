module ApplicationHelper
  def controller?(*controller)
    controller.include?(params[:controller].to_sym)
  end

  def action?(*action)
    action.include?(params[:action].to_sym)
  end
end

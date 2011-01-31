
class ActionController::Base
  private
  def assign_shortcuts_with_debugging_toolbar_support(request, response)
    assign_shortcuts_without_debugging_toolbar_support(request, response)
    response.template.extend(RailsDebuggingToolbar::Extensions::ActionView) if request.parameters.has_key?(:template_debug)
  end
  alias_method_chain :assign_shortcuts, :debugging_toolbar_support
end


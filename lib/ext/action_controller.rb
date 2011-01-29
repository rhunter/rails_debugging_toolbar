
class ActionController::Base
  private
  def initialize_template_class_with_debugging_toolbar_support(response)
    initialize_template_class_without_debugging_toolbar_support(response)
    response.template.extend(RailsDebuggingToolbar::Extensions::ActionView)
  end
  alias_method_chain :initialize_template_class, :debugging_toolbar_support
end


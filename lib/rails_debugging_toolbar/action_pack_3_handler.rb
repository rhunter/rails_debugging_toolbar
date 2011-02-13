require 'rails_debugging_toolbar/extensions'
require 'action_pack'

class ActionController::Base
  include RailsDebuggingToolbar::Extensions::ActionController
end


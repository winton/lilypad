# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  def rescue_action(exception)
    super
    request.env['rack.lilypad.component'] = params[:controller]
    request.env['rack.lilypad.action'] = params[:action]
    raise exception
  end
  
  def pulse
    raise TestError, 'Test'
  end
end

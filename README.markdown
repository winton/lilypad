Lilypad
=======

Hoptoad notifier for Rack-based frameworks.

Install
-------

<pre>
sudo gem install lilypad --source http://gemcutter.org
</pre>

Rails
-----

**config/environment.rb**

<pre>
require 'rack/lilypad'

Rails::Initializer.run do |config|
  config.middleware.insert_after(ActionController::Failsafe, Rack::Lilypad, 'hoptoad_api_key_goes_here')
end
</pre>

**app/controllers/application_controller.rb**:

<pre>
class ApplicationController < ActionController::Base

  def rescue_action(exception)
    super
    ENV['RACK_ENV'] = ENV['RAILS_ENV']
    request.env['rack.lilypad.component'] = params[:controller]
    request.env['rack.lilypad.action'] = params[:action]
    raise exception
  end
end
</pre>

Sinatra
-------

<pre>
require 'rack/lilypad'

class MyApp < Sinatra::Application
  enable :raise_errors # not necessary for Sinatra::Base
  use Rack::Lilypad, 'hoptoad_api_key_goes_here'
end
</pre>

Filters
-------

Don't send certain environment variables to Hoptoad.

<pre>
use Rack::Lilypad, 'hoptoad_api_key_goes_here' do |hoptoad|
  hoptoad.filters << %w(AWS_ACCESS_KEY AWS_SECRET_ACCESS_KEY AWS_ACCOUNT SSH_AUTH_SOCK)
end
</pre>

Direct Access
-------------

Send exceptions to Hoptoad from a rescue block.

<pre>
begin
  raise 'Test'
rescue Exception => e
  Rack::Lilypad.notify(e)
end
</pre>

Log
---

See what you are sending and receiving from Hoptoad.

<pre>
use Rack::Lilypad, 'hoptoad_api_key_goes_here' do |hoptoad|
  hoptoad.log = '/var/www/log/hoptoad.log'
end
</pre>

Compatibility
-------------

Tested with Ruby 1.8.6, 1.8.7, and 1.9.1.

Thanks
------

Lilypad wouldn't have happened without [rack_hoptoad](http://github.com/atmos/rack_hoptoad), [toadhopper](http://github.com/toolmantim/toadhopper), [Builder](http://builder.rubyforge.org), and [Nokogiri](http://nokogiri.org).
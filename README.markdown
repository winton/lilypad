Lilypad
=======

Hoptoad notifier for Rack-based frameworks.

Install
-------

<pre>
sudo gem install lilypad --source http://gemcutter.org
</pre>

Basic Usage
-----------

<pre>
require 'lilypad'
use Rack::Lilypad, 'hoptoad_api_key_goes_here'
</pre>

Rails
-----

**config/environment.rb**

<pre>
require 'lilypad'

Rails::Initializer.run do |config|
  config.middleware.insert_after(ActionController::Failsafe, Rack::Lilypad)
end

Lilypad do
  api_key 'hoptoad_api_key_goes_here'
  rails
end
</pre>

Sinatra
-------

<pre>
require 'lilypad'

class MyApp < Sinatra::Application
  use Rack::Lilypad do
    api_key 'hoptoad_api_key_goes_here'
    sinatra
  end
end
</pre>

Error Redirection
-----------------

Conditionally redirect errors to different Hoptoad buckets.

<pre>
Lilypad do
  api_key do |env, exception|
    if exception && exception.message =~ /No route matches/
      'hoptoad_api_key_goes_here'
    elsif env && env['HTTP_USER_AGENT'] =~ /Googlebot/
      'hoptoad_api_key_goes_here'
    else
      'hoptoad_api_key_goes_here'
    end
  end
end
</pre>

Notify
------

Send exceptions to Hoptoad from a rescue block.

<pre>
begin
  raise 'Test'
rescue Exception => e
  Lilypad.notify(e)
end
</pre>

Deploy
------

Send deploy notifications to Hoptoad.

**deploy.rb**

<pre>
require 'capistrano/lilypad'
Lilypad { api_key 'hoptoad_api_key_goes_here' }
</pre>

Or you can do it manually:

<pre>
Lilypad.deploy(
  :environment => 'production',
  :repository => 'git@github.com:winton/lilypad.git',
  :revision => '8acc488967085987f0a9f2c662383119f83e1bb8',
  :username => 'winton'
)
</pre>

Options
-------

Below are the available options and their default values:

<pre>
Lilypad do
  api_key nil
  environments %w(production staging)
  deploy_url 'http://hoptoadapp.com:80/deploys.txt'
  notify_url 'http://hoptoadapp.com:80/notifier_api/v2/notices'
  filters []  # Array of environment variables to hide from Hoptoad
  limit 100   # Consecutive error limit
  log nil     # Path of Hoptoad log
  rails       # Requires the Rails adapter
  sinatra     # Requires the Sinatra adapter
end
</pre>

Compatibility
-------------

Tested with Ruby 1.8.6, 1.8.7, and 1.9.1.

Thanks
------

Lilypad wouldn't have happened without [rack_hoptoad](http://github.com/atmos/rack_hoptoad), [toadhopper](http://github.com/toolmantim/toadhopper), [Builder](http://builder.rubyforge.org), and [Nokogiri](http://nokogiri.org).
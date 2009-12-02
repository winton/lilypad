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

In **config/environment.rb**:

<pre>
require 'rack/lilypad'

Rails::Initializer.run do |config|
  ENV['RACK_ENV'] = ENV['RAILS_ENV']
  config.middleware.use Rack::Lilypad, 'hoptoad_api_key_goes_here'
end
</pre>

Sinatra
-------

<pre>
require 'rack/lilypad'

class MyApp < Sinatra::Default
  enable :raise_errors
  use Rack::Lilypad, 'hoptoad_api_key_goes_here'
end
</pre>

Filters
-------

Don't send certain environment variables to Hoptoad.

<pre>
use Rack::Lilypad, 'hoptoad_api_key_goes_here' do |hoptoad|
  hoptoad.filters << %w(AWS_ACCESS_KEY  AWS_SECRET_ACCESS_KEY AWS_ACCOUNT SSH_AUTH_SOCK)
end
</pre>

Debug
-----

See what you are sending and receiving from Hoptoad.

<pre>
use Rack::Lilypad, 'hoptoad_api_key_goes_here' do |hoptoad|
  hoptoad.log = '/var/www/log/hoptoad.log'
end
</pre>

Thanks
------

Lilypad wouldn't have happened without [rack_hoptoad](http://github.com/atmos/rack_hoptoad), [toadhopper](http://github.com/toolmantim/toadhopper), [Builder](http://builder.rubyforge.org), and [Nokogiri](http://nokogiri.org).
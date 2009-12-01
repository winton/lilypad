Lilypad
=======

Hoptoad notifier for Rack-based frameworks.

Install
-------

<pre>
sudo gem install lilypad --source http://gemcutter.org
</pre>

Use it
------

<pre>
require 'rack/lilypad'
use Rack::Lilypad, 'hoptoad_api_key_goes_here'
</pre>

To specify environment filters:

<pre>
use Rack::Lilypad, 'hoptoad_api_key_goes_here' do |hoptoad|
  hoptoad.filters << %w(AWS_ACCESS_KEY  AWS_SECRET_ACCESS_KEY AWS_ACCOUNT SSH_AUTH_SOCK)
end
</pre>

In Rails, you will need to do this in the <code>Rails::Initializer.run</code> block in environment.rb:

<pre>
ENV['RACK_ENV'] = ENV['RAILS_ENV']
config.middleware.use Rack::Lilypad, 'hoptoad_api_key_goes_here'
</pre>

Debug
-----

Use the log option to see what is happening:

<pre>
use Rack::Lilypad, 'hoptoad_api_key_goes_here' do |hoptoad|
  hoptoad.log = '/var/www/log/hoptoad.log'
end
</pre>

Thanks
------

Lilypad wouldn't have happened without [rack_hoptoad](http://github.com/atmos/rack_hoptoad), [toadhopper](http://github.com/toolmantim/toadhopper), [Builder](http://builder.rubyforge.org), and [Nokogiri](http://nokogiri.org).
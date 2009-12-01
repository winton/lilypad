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
require 'rubygems'
require 'rack/lilypad'

use Rack::Lilypad, 'fd48c7d26f724503a0280f808f44b339fc65fab8'
</pre>

To specify environment filters:

<pre>
use Rack::Lilypad, 'fd48c7d26f724503a0280f808f44b339fc65fab8' do |hoptoad|
	hoptoad.filters << %w(AWS_ACCESS_KEY  AWS_SECRET_ACCESS_KEY AWS_ACCOUNT SSH_AUTH_SOCK)
end
</pre>
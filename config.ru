require 'rack/timeout'
use Rack::Timeout
Rack::Timeout.timeout = 240 # this line is optional. if omitted, default is 15 seconds.

require './server.rb'

# use Rack::Reloader
run Sinatra::Application

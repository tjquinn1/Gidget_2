require 'bundler/setup'
require 'librato-rack'

use Librato::Rack

def application(env)
  case env['PATH_INFO']
  when '/status/204'
    [204, {"Content-Type" => 'text/html'}, ["Status 204!"]]
  when '/exception'
    raise 'exception raised!'
  when '/slow'
    sleep 0.3
    [200, {"Content-Type" => 'text/html'}, ["Slow request"]]
  else
    [200, {"Content-Type" => 'text/html'}, ["Hello!"]]
  end
end

run method(:application)
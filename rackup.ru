require 'http'
use HTTP::FromRack

map "/" do
  require 'testapp'
end

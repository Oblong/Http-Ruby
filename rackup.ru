require 'http'
require 'testapp'

map "/" do
  use HTTP::FromRack
  run MyTest.new
end

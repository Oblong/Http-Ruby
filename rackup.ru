require 'http'

use HTTP::FromRack, :paths => [ '/nodestyle' ]

map "/" do
  require 'rubystyle'
  run RubyStyle.new
end

map "/nodestyle" do
  require 'nodestyle'
end

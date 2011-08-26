server = HTTP::server

server.on('request') { |request, response| 
  request['key'] = 'value'
  response.writeHead 200, "Content-Type" => "text/html"
  response.doEnd "This is the node style calling convention. You can return <a href=/>to the root</a> to get the traditional ruby style."
  puts "Content After"
}

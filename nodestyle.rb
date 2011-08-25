server = HTTP::server

server.on('request') { |request, response| 
  response.writeHead 200, "Content-Type" => "text/html"
  response.write "This is the node style calling convention. You can return <a href=/>to the root</a> to get the traditional ruby style."
  response.doEnd
}

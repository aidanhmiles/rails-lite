require 'webrick'

server = WEBrick::HTTPServer.new :Port => 8080

trap('INT') { server.shutdown }

def go(req, res)

	render_content("hello world","text/html")
end

server.mount_proc '/' do |req, res|
	res.content_type = "text/text"
	res.body = "#{req.path}"
end





server.start

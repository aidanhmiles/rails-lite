require 'json'
require 'webrick'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
		@session_cookie = req.cookies.select {|c| c.name == '_rails_lite_app' }.first
		@session_cookie ? @cookhash = JSON.parse(@session_cookie.value) : @cookhash = {}
  end

  def [](key)
		@cookhash[key]
  end

  def []=(key, val)
		@cookhash[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
		res.cookies << WEBrick::Cookie.new('_rails_lite_app', @cookhash.to_json)
  end
end

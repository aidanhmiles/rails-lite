require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
		@params = route_params
		@params = parse_www_encoded_form(req.query_string) if req.query_string
		# why is the below necessary, and yet not above?
		if req.body
			@params = parse_www_encoded_form(req.body) 
		end

		#	parse_www_encoded_form(req.body)
		#	route_params
		# @params.merge(route_params)
		# @params
  end

  def [](key)
		@params[key]
  end

  def to_s
		@params.to_s
  end

  # private
  # this should return deeply nested hash
  # argument format
  # ("user[address][street]=main&user[address][zip]=89436")
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
		pairs = URI.decode_www_form(www_encoded_form)
		merged_hash = {}
		pairs.each do |pair|
			current_hash = merged_hash
			keys = parse_key(pair.first)
			keys.each do |key|
				if current_hash.has_key?(key)
					current_hash = current_hash[key]
				elsif key != keys.last
					current_hash[key] = {}
					current_hash = current_hash[key]
				elsif 
					current_hash[key] = pair.last
				end
			end
		end 
		merged_hash
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
		key.scan(/\w+/)
  end
end

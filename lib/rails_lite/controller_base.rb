require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'


class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
		@req, @res, @route_params = req, res, route_params
		@already_built_response = false
		@params = Params.new(req, route_params)
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
		raise AlreadyRenderedError if already_rendered?
			
		@res.content_type = type
		@res.body = content 
		@already_built_response = true
		Session.new(@req).store_session(@res)
  end

  # helper method to alias @already_rendered
  def already_rendered?
		@already_built_response
  end

  # set the response status code and header
  def redirect_to(url)
		raise AlreadyRenderedError if already_rendered?
		@res.status = 302
		@res["location"] = url
		@already_built_response = true
  end


  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
		rails AlreadyRenderedError if already_rendered?
		template = ERB.new(File.read("views/#{self.class.name.underscore.downcase}/#{template_name}.html.erb")).result(binding)
		render_content(template, "text/html")
		@already_built_response = true
  end

  # method exposing a `Session` object
  def session
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
		self.send(name)
		unless @already_built_response
			render(name)
		end
  end
end

class AlreadyRenderedError < RuntimeError
end

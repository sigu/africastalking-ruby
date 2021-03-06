require "AfricasTalking/version"
require 'httparty'
require "AfricasTalking/Sms"
require "AfricasTalking/Airtime"
require "AfricasTalking/Payments"
require "AfricasTalking/Voice"
require "AfricasTalking/Token"
require "AfricasTalking/Application"

module AfricasTalking
	DEBUG            = false
	@username = nil
	@apikey = nil
	@response_code = nil

	class Initialize
		attr_accessor :username, :apikey
		def initialize username, apikey
			@username    = username
			@apikey      = apikey 
		end
		
		def sms
			return Sms.new @username, @apikey		
		end
	
		def payments
			return Payments.new @username, @apikey
		end
	
		def airtime
			return Airtime.new @username, @apikey
		end
	
		def voice
			return Voice.new @username, @apikey
		end
	
		def token
			return Token.new @username, @apikey
		end
	
		def application
			return Application.new @username, @apikey
		end
	end

	class AfricasTalkingException < Exception
		# error handling appear here
		# def initialize(msg="My default message")
		#     super
		# end

	end


	private 
		
		def sendNormalRequest url_, data_ = nil
			uri		 	     = URI.parse(url_)
			http		     = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl     = true
			headers = {
				"apikey" => @apikey,
				"Accept" => "application/json"
			}
			if(data_ != nil)
				request = Net::HTTP::Post.new(uri.request_uri)
				request.set_form_data(data_)
			else
				request = Net::HTTP::Get.new(uri.request_uri)
			end
			request["apikey"] = @apikey
			request["Accept"] = "application/json"
			response          = http.request(request)

			if (DEBUG)
				puts "Full response #{response.body}"
			end

			@response_code = response.code.to_i
			return response.body
		end

		def sendJSONRequest (url_, data_)
			uri	       = URI.parse(url_)
			http         = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = true
			req          = Net::HTTP::Post.new(uri.request_uri, 'Content-Type'=>"application/json")
			
			req["apikey"] = @apikey
			req["Accept"] = "application/json"
			
			req.body = data_.to_json

			response  = http.request(req)
			
			if (DEBUG)
				puts "Full response #{response.body}"
			end

			@response_code = response.code.to_i
			return response.body
		end

		def validateParamsPresence? params, values
			status =  values.each{ |v|
				if !params.key?(v)
					raise AfricasTalkingException, "Please make sure your params has key #{v}"
				elsif v.empty?
					raise AfricasTalkingException, "Please make sure your key #{v} is not empty"
				end
			}
			return true

		end
			
end

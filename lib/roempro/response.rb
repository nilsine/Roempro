# -*- encoding : UTF-8 -*-

require 'net/http'
require 'json'

module Roempro

  ##
  # Handle the response from Oempro API.
  #
  # It allow to easly access to the response parts.
  #
  # <b>Only work with JSON formated response!</b>
  class Response < Roempro::Class

    ##
    # Create a new Roempro::Response object.
    #
    # === Parameters
    # <b>URI::HTTPResponse</b>
    def initialize(http_response)
      unless http_response.kind_of? Net::HTTPResponse
        raise ArgumentError, "#{self.class}#new only support Net::HTTPResponse as input"
      end

      @response = JSON.parse(http_response.body)
      @response['HttpSuccess'] = http_response.is_a? Net::HTTPSuccess
      @response = Hash[@response.map { |k,v| [k.downcase, v] }]

    rescue ArgumentError => message
      puts message
    rescue JSON::ParserError
      # Report the exception message ?
      puts "JSON parser fail to compute the API's response"
    end

    ##
    # As well as Roempro::Request, Roempro::Response return a response part
    # according the called method.
    #
    # The followed pattern is simple. To access to a response part just call
    # it.
    #
    # ==== Examples
    #
    #   > req = Roempro::Request.new
    #     => #<Roempro::Request>
    #   > res = req.get_emails
    #     => #<Roempro::Response @response={"success"=>true,
    #        #  "errorcode"=>0, "errortext"=>"", "totalemailcount"=>1,
    #        #  "emails"=>[{"EmailID"=>"1"[...]}], "httpsuccess"=>true}>
    #   > res.success
    #     => true
    #   > res.totalemailcount
    #     => 1
    def method_missing(method_id, *args)
      if args.any?
        raise ArgumentError, "#{self.class}##{method_id.to_s} doesn't accept any agument"
      end

      @response[method_id.to_s.split('_').join('')]

    rescue ArgumentError => message
      puts message
    end
  end
end

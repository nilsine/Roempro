# -*- encoding : UTF-8 -*-

require 'net/http'
require 'json'

module Roempro
  class Response < Roempro::Class
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

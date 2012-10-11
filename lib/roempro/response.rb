# -*- encoding : utf-8 -*-

require 'net/http'
require 'json'

module Roempro
  class Response
    def initialize(http_response)
      unless http_response.kind_of? Net::HTTPResponse
        raise ArgumentError, "#{self.class} only support Net::HTTPResponse as input"
      end

      @response = JSON.parse(http_response.body)
      @response['HttpSuccess'] = http_response.is_a? Net::HTTPSuccess

    rescue ArgumentError => message
      puts message
    end

    def method_missing(method_id, *args)
      if args.any?
        raise ArgumentError, "#{method_id.to_s} doesn't accept any agument"
      end

      return @response[method_id.to_s.split(/_/).map!(&:capitalize).join('')]

    rescue ArgumentError => message
      puts message
    end

    def success
      @success
    end
  end
end

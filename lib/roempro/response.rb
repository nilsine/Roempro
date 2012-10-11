require 'net/http'
require 'json'

module Roempro
  class Response
    def initialize(http_response)
      raise "#{self.class} only support Net::HTTPResponse as input" unless http_response.kind_of? Net::HTTPResponse

      @response = JSON.parse(http_response.body)
      @response['HttpSuccess'] = http_response.is_a? Net::HTTPSuccess
    end

    def method_missing(method_id, *args)
      raise "Unable to set values" if args.any?

      return @response[method_id.to_s.split(/_/).map!(&:capitalize).join('')]
    end

    def success
      @success
    end
  end
end

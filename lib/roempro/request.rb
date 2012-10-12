# -*- encoding : utf-8 -*-

require "net/http"
require "uri"

module Roempro
  ##
  # This specific class is responsible to actually perform
  # the request to the given Oempro API.
  #
  # It give a way to merely deal with the API handling all
  # the undestood commands. Actually, it build the request
  # chain from the methods names and the hash submit as argument.
  #
  # For instance, to fetch all emails :
  #
  #   req = Roempro::Request.new
  #   # => <#Roempro::Request>
  #   req.emails.get    # It does the trick
  #
  # Then, `req.emails.get` return Roempro::Response object.
  # See Roempro::Response to learn more.
  class Request

    ##
    # Provide a new Roempro::Request object
    def initialize(params={})
      @url , @user, @password = params[:url], params[:username], params[:password]
    end

    def method_missing(method_id, *args)
      unless args.empty? or args.first.kind_of? Hash
        raise ArgumentError, "#{self.class}##{method_id.to_s} only accept hash argument"
      end

      login unless logged_in?

      if logged_in?
        perform (args.first || {}).merge :command => method_id.to_s.split('_').map(&:capitalize).reverse.join('.')
      end

    rescue ArgumentError => message
      puts message
    end

    def last_response
      @last_response
    end

    def logged_in?
      @session_id ? true : false;
    end

    def login
      unless logged_in?
        unless @user and @password
          raise ArgumentError, "You have to submit your username and password to log into Oempro"
        end

        perform :command => "User.Login",
                :username => @user,
                :password => @password,
                :disablecaptcha => true

        unless @last_response.success
          raise RuntimeError, @last_response.error_text.join("\n")
        end

        @session_id = @last_response.session_id
      end

    rescue ArgumentError => message
      puts message
    end

    private

      def perform(query={})
        unless @url
          raise ArgumentError, "Unable to perform the request : Uknown URL to Oempro"
        end
        unless query.nil? or query.kind_of? Hash
          raise ArgumentError, "Unable to perform the request : params have to be a hash"
        end

        query ||= {}
        query.merge! :sessionid => @session_id, :responseformat => 'JSON'

        uri = URI(@url)
        uri.query = URI::encode_www_form query

        @last_response = Roempro::Response.new(Net::HTTP.get_response(uri))
      end
  end
end

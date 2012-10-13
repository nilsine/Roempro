# -*- encoding : UTF-8 -*-

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
  class Request < Roempro::Class

    ##
    # Provide a new Roempro::Request object
    def initialize(params={})
      @url      = params[:url]      if params[:url].is_a?       String
      @username = params[:username] if params[:username].is_a?  String
      @password = params[:password] if params[:password].is_a?  String

      if @url or @username or @password
        @session_id = nil
      end
    end

    def command(command_name, *args)
      unless args.flatten.compact.empty? or args.flatten.first.kind_of? Hash
        raise ArgumentError, "#{self.class}##{command_name.to_s} only accept hash argument"
      end

      login unless logged_in?

      if logged_in?
        perform (args.flatten.first || {}).merge :command => command_name
      end

    rescue ArgumentError => message
      puts message
    end

    def method_missing(method_id, *args)
      unless args.empty? or args.first.kind_of? Hash
        raise ArgumentError, "#{self.class}##{method_id.to_s} only accept hash argument"
      end

      command(method_id.to_s.split('_').map(&:capitalize).reverse.join('.'), args)

    rescue ArgumentError => message
      puts message
    end

    def last_response
      @last_response
    end

    def logged_in?
      if defined? @session_id
        @session_id ? true : false;
      else
        Base.session_id ? true : false;
      end
    end

    def login
      unless logged_in?
        unless (@username and @password) or (Config.username and Config.password)
          raise ArgumentError, "You have to submit your username and password to log into Oempro"
        end

        perform :command => "User.Login",
                :username => @username || Config.username,
                :password => @password || Config.password,
                :disablecaptcha => true

        unless @last_response.success
          raise RuntimeError, @last_response.error_text.join("\n")
        end

        if defined? @session_id
          @session_id = @last_response.session_id
        else
          Base.session_id = @last_response.session_id
        end
      end

    rescue ArgumentError => message
      puts message
    end

    private

      def perform(query={})
        unless @url or Config.url
          raise ArgumentError, "Unable to perform the request : Uknown URL to Oempro"
        end
        unless query.nil? or query.kind_of? Hash
          raise ArgumentError, "Unable to perform the request : params have to be a hash"
        end

        query ||= {}
        query.merge! :sessionid => @session_id || Base.session_id, :responseformat => 'JSON'

        uri = URI(@url || Config.url)
        uri.query = URI::encode_www_form query

        @last_response = Roempro::Response.new(Net::HTTP.get_response(uri))
      end
  end
end

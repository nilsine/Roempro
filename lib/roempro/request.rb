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
      if not @query
        if args.any?
          raise ArgumentError, "#{method_id.to_s} doesn't accept any arguments"
        end

        @query = { :command => [method_id.to_s.capitalize] }
        return self
      else
        unless args.empty? or args.first.kind_of? Hash
          raise ArgumentError, "#{self.class}##{method_id.to_s} only accept hash argument"
        end

        @query[:command].push(method_id.to_s.capitalize)

        perform args.first if login
      end

    rescue ArgumentError => message
      @query = nil
      puts message
      return self
    end

    private

      def perform(params={})
        unless @url
          raise ArgumentError, "Unable to perform the request : Uknown URL to Oempro"
        end
        unless params.nil? or params.kind_of? Hash
          raise ArgumentError, "Unable to perform the request : params have to be a hash"
        end

        @query[:command] = @query[:command].join(".")
        @query.merge!({ :sessionid => @session_id }).merge!({ :responseformat => 'JSON' })
        @query.merge!(params.delete_if do |key|
          %W(command responseformat).include? key.to_s
        end) unless params.nil?

        uri = URI(@url)
        uri.query = URI::encode_www_form @query
        @query = nil

        Roempro::Response.new Net::HTTP.get_response(uri)
      end

      def login
        if not @session_id
          unless @user and @password
            raise ArgumentError, "You have to submit your username and password to log into Oempro"
          end

          last_query = @query
          @query = { :command => ["User", "Login"] }

          response = perform :username => @user, :password => @password, :disablecaptcha => true

          @query = last_query

          # raise RuntimeError, response.error_text.join("\n") if not response.success
          @session_id = response.session_id if response.http_success
        end

      rescue ArgumentError => message
        puts message
      ensure
        return @session_id
      end
  end
end

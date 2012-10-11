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
      @url = params[:url]
      @user = params[:username]
      @password = params[:password]
    end

    def method_missing(method_id, *args)

      login

      if not @query
        raise "#{method_id.to_s} doesn't accept any arguments" if args.any?
        @query = { :command => [method_id.to_s.capitalize] }
        return self
      else
        raise "#{self.class}##{method_id.to_s} only accept hash argument" unless args.empty? or
                                                                                 args.first.kind_of? Hash

        @query[:command].push(method_id.to_s.capitalize)
        perform args.first
      end
    end

    private

      def perform(params={})
        raise "Unable to perform the request : Uknown URL to Oempro" if not @url
        raise "Unable to perform the request : params have to be a hash" if params.empty?

        @query[:command] = @query[:command].join(".")
        @query.merge!({ :responseformat => 'JSON' }).merge!(params.delete_if do |key|
          %W(command responseformat).include? key.to_s
        end)

        uri = URI(@url)
        uri.query = URI::encode_www_form @query
        @query = nil

        puts uri.to_s

        # return Net::HTTP.get_response(uri)
      end

      def login
      raise "You have to submit your username and password to log into Oempro" if not @user or
                                                                                  not @password

        @query = { :command => ["User", "Login"] }
        perform :username => @user, :password => @password, :disablecaptcha => true
      end
  end
end

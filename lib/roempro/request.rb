require "net/http"
require "uri"

module Roempro
  ##
  # Entity which actually perform the request to the given Oempro API.
  #
  # It give a way to merely deal with the API handling all the undestood
  # commands. Actually, it build the request chain from the methods names and
  # the hash submited as argument.
  #
  # For instance, to fetch all emails :
  #
  #   req = Roempro::Request.new
  #   # => #<Roempro::Request>
  #   req.get_emails    # Will actually retrieve all emails.
  class Request < Roempro::Class

    ##
    # How many times a request can retry before abord it
    #
    MaxRetry = 3

    ##
    # Return a new Roempro::Request object
    #
    # Paramters are optionals. Those which are missing will
    # be got from Roempro::Config.
    #
    # === Parameters
    # [Hash]
    #   [:url]
    #     Define the path to the desired Oempro API
    #   [:username]
    #     The username to use for signin
    #   [:password]
    #     The user's password
    def initialize(params={})
      @username = params[:username].to_s if params[:username]
      @password = params[:password].to_s if params[:password]
      @url = if params[:url]
        if uri = URI.parse(params[:url]) and
           uri.instance_of? URI::HTTPS
            raise ArgumentError, "Roempro::Request doesn't support SSL yet"
        end
        if uri.instance_of? URI::Generic
          "http://" + params[:url].to_s
        elsif uri.kind_of?  URI::HTTP
          params[:url].to_s
        end
      end

      if @url or @username or @password
        @session_id = nil
      end

      hide :password

    rescue URI::Error, ArgumentError => message
      puts message
    end

    ##
    # Fallback to request a command to the Oempro API.
    #
    # For the most commands, just call them using the <i>method *to*
    # command</i> pattern (see method_missing) should work fine. Nevertheless, few command in the
    # Oempro API just cannot be send by this way, because of how
    # Roempro::Request compute a called method to a proper command name.
    #
    # === Parameters
    # [String]
    #   The command name, as defined in the Oempro API documentation.
    # [Hash]
    #   Parameters to submit with the command.
    def command(command_name, *args)
      unless args.flatten.compact.empty? or args.flatten.first.kind_of? Hash
        raise ArgumentError, "#{self.class}##{command_name.to_s} only accept hash argument"
      end

      # Perform the same request until it success or Roempro cannot sign in
      # or the max retry has been reached
      begin
        may_signin
        perform((args.flatten.first || {}).merge :command => command_name)
      end while @retry and @retry < MaxRetry

      quit
      last_response
    rescue ArgumentError => message
      puts message
    end

    ##
    # Provide to the Object's user a flexible way to command to the Oempro API.
    #
    # It work with the following pattern :
    #
    #   Romepro::Request#given_command
    #   # Use "Command.Given" as command to send to the Oempro API
    #
    # === Examples
    #
    #   > req = Roempro::Request.new
    #     => #<Roempro::Request>
    #   > req.get_emails    # GET [...]api.php?command=Emails.Get[...]
    def method_missing(method_id, *args)
      unless args.empty? or args.first.kind_of? Hash
        raise ArgumentError, "#{self.class}##{method_id.to_s} only accept hash argument"
      end

      command(method_id.to_s.split('_').map(&:capitalize).reverse.join('.'), args)

    rescue ArgumentError => message
      puts message
    end

    ##
    # Return the last response answered by the Oempro API
    #
    # === Return
    # Roempro::Response
    def last_response
      @last_response
    end

    ##
    # Tell if Roempro signed in the Oempro API.
    #
    # If the current object has been created with a specific url, username or
    # password else than the default configuration, then, it check the
    # <i>session id</i> stored within this Roempro::Request object.
    #
    # Else, it look for <i>session id</i> kept into Roempro::Base.
    def signed_in?
      # Force sign in again if defined
      @resignin, @session_id, Base.session_id = nil if @resignin

      is_signed_in = (@session_id || Base.session_id) ? true : false
      @resignin = nil if is_signed_in
      is_signed_in
    end

    ##
    # Sign in the Oempro API
    #
    # If the given url, username or password are different from the default
    # ones, then it use them and the returned <i>session id</i> is stored
    # within this Roempro::Request object.
    #
    # Else, the <i>session id</i> is kept into Roempro::Base
    def may_signin
      unless signed_in?
        unless (@username and @password) or (Config.username and Config.password)
          raise ArgumentError, "You have to submit your username and password to sign in Oempro"
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
          signed_in?
        else
          Base.session_id = @last_response.session_id
          signed_in?
        end
      end

    rescue ArgumentError => message
      puts message
    end

    private

      ##
      # Perform a request to the Oempro API.
      #
      # It look for specific url, username or password and use it. Else, it
      # look for the default configuration.
      #
      # === Parameters
      # [Hash]
      #   Parameters to submit with the command
      #
      # === Return
      # Roempro::Response
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
        @last_response = Roempro::Response.new(Net::HTTP.post_form(uri, query))

        if @last_response.errorcode == 99998 # session timeouted
          @resignin = true
          @retry = @retry.to_i + 1 if query[:command] != 'User.Login'
        else
          @resignin = nil
        end
      end

      ##
      # Clean up few instance variables used to define if the request have to
      # be performed again. Call this method main the Request is over.
      def quit
        @retry, @resignin = nil
      end
  end
end

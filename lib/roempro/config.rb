# -*- encoding : UTF-8 -*-

module Roempro
  class Config < Roempro::Class
    cattr_reader :url, :username, :password

    ##
    # Load the default configuration into Roempro::Config.
    #
    # Once the default configuration loaded into this object, all new
    # Roempro's components will use those informations to configure
    # themself. Unless a specific configuration is provide at creation.
    #
    # === Parameters
    # [Hash]
    #   [:url]
    #     Define the path to the desired Oempro API
    #   [:username]
    #     The username to use for login
    #   [:password]
    #     The user's password
    def self.load_from_hash(params={})
      params = Hash[params.map {|k,v| [k.to_sym,v] }]

      @@username = params[:username].to_s if params[:username]
      @@password = params[:password].to_s if params[:password]
      @@url = if params[:url]
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

      return self if @@url or @@username or @@password

    rescue URI::Error, ArgumentError => message
      puts message
    end
  end
end

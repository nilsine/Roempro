# -*- encoding : UTF-8 -*-

module Roempro
  class Config < Roempro::Class
    cattr_reader :url, :username, :password

    def self.load_from_hash(params={})
      params = Hash[params.map {|k,v| [k.to_sym,v] }]

      @@url = params[:url] if params[:url].is_a? String
      @@username = params[:username] if params[:username].is_a? String
      @@password = params[:password] if params[:password].is_a? String

      params
    end
  end
end

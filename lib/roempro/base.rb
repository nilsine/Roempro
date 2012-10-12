module Roempro
  def self.load_config(params={})
    params = Hash[params.map {|k,v| [k.to_sym,v] }]

    @@url = params[:url] if params[:url].is_a? String
    @@username = params[:username] if params[:username].is_a? String
    @@password = params[:password] if params[:password].is_a? String

    params
  end
end

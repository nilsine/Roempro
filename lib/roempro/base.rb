##
# Roempro, a shortcut for Ruby Oempro, is a Ruby wrapper for the Oempro API,
# which provide a way to deal with the API easily.
#
# It's splited into mutiples sub-classes :
# * Roempro::Base
# * Roempro::Config
# * Roempro::Request
# * Roempro::Response
#
# Actually, Roempro::Class is also available but only used internaly, to give
# more power to the Ruby class.
#
# Roempro::Base is responsible to give the commun stuff and hold some global
# informations. Roempro::Config is responsible to hold the default
# configuration. It give a way to efficiently init Roempro in Rails 3, with
# intializers. Roempro::Request is responsible to handle what is needed to
# actually deal with the API. It also provide severals other abilities.
# Roempro::Response is responsible to store the API response. More, it yields
# means to easily acces to the response component.
module Roempro

  ##
  # Hold few informations used by the Roempro's components.
  #
  # For instance, it keep in mind the session_id when the user is logged in
  # the API. Thus, all new Roempro::Request object will used this session_id,
  # unless explicitly told them to not use it.
  class Base < Roempro::Class
    cattr_accessor :session_id
  end
end

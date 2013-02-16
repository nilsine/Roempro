# ChangeLog

## 0.2 (2013-02-16)

  * Retry the request when session timeout.
  * Use POST instead of GET method.
  * Improve securty hiding Oempro password from Request inspect.

## 0.1 (2012-10-14)

  * Write documentation
  * Improve url validation into Roempro::Config and Roempro::Request contructors.
  * Handle global session id as well as instance one.
  * Improve Roempro::Request intializer.
  * Make Roempro::Request and Roempro::Response inherit from Roempro::Class.
  * Split Roempro content into Roempro::Base and Roempro::Config.
  * Create Roempro::Class to override default class.
  * Create Rails 3 initializer.
  * New method Roempro::Request#command to submit the command by submit a string.
  * Keep the last response into request.
  * Handle login stuff.
  * Improve exception handling.
  * Create Roempro::Response.
  * Create Roempro::Request class.
  * Set up description and summary in gemspec file.
  * Initialise roempro gem.

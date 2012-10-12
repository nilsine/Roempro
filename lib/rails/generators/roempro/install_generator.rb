# -*- encoding: utf-8 -*-

module Roempro
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc 'Create the Roempro gem configuration file at config/roempro.yml, and an initializer at config/initializers/roempro.rb'

      def self.source_root
        @roempro_source_root = File.expand_path("../templates", __FILE__)
      end

      def create_config_file
        template 'roempro.yml', File.join('config', 'roempro.yml')
      end

      def create_initializer_file
        template 'initializer.rb', File.join('config', 'initializers', 'roempro.rb')
      end
    end
  end
end

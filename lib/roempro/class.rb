# -*- encoding : UTF-8 -*-

module Roempro
  class Class

    def self.cattr_reader(*attributes)
      attributes.map!(&:to_sym).each do |attr|
        class_eval(<<-EOS, __FILE__, __LINE__ + 1)
          @@#{attr} = nil unless defined? @@#{attr}

          def self.#{attr}
            @@#{attr}
          end
        EOS
      end
    end

    def self.cattr_writer(*attributes)
      attributes.map!(&:to_sym).each do |attr|
        class_eval(<<-EOS, __FILE__, __LINE__ + 1)
          @@#{attr} = nil unless defined? @@#{attr}

          def self.#{attr}=(value)
            @@#{attr} = value
          end
        EOS
      end
    end

    def self.cattr_accessor(*attributes)
      cattr_reader *attributes
      cattr_writer *attributes
    end
  end
end

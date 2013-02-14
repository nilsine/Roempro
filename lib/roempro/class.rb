module Roempro

  ##
  # Few improvements appended to the default Ruby *class*. This aim to be used
  # by the others Roempro's components, to provide them tools to help with
  # development.
  #
  # To achieve this, the Roempro component must inhérite from this specific
  # Roempro::Class.
  class Class

    ##
    # Hold instance variables that have to be secrets from outside of the
    # class.
    @@hidden_vars = []

    ##
    # Create the reader accessors for the given attributes.
    #
    # <b>Planed to be used by the inherited class.</b>
    #
    # === Parameters
    # [Array]
    #   Named variables which required the accessors to be made.
    #
    # === Examples
    #
    #   Roempro.module_eval do
    #     class SomeClass < Roempro::Class
    #       cattr_reader :var
    #     end
    #   end
    #
    #   > Roempro::SomeClass.var
    #     => nil
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

    ##
    # Create the writer accessors for the given attributes.
    #
    # <b>Planed to be used by the inherited class.</b>
    #
    # === Parameters
    # [Array]
    #   Named variables which required the accessors to be made.
    #
    # === Examples
    #
    #   Roempro.module_eval do
    #     class SomeClass < Roempro::Class
    #       cattr_writer :var
    #     end
    #   end
    #
    #   > Roempro::SomeClass.var = "Hello world!"
    #     => "Hello world!"
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

    ##
    # Create both reader/writer accessors for the given attributes.
    #
    # <i>See cattr_reader and cattr_writer, to learn more.</i>
    #
    # <b>Planed to be used by the inherited class.</b>
    #
    # === Examples
    #
    #   Roempro.module_eval do
    #     class SomeClass < Roempro::Class
    #       cattr_reader :var
    #     end
    #   end
    #
    #   > Roempro::SomeClass.var = "Hello world!"
    #     => "Hello world!"
    #   > Roempro::SomeClass.var
    #     => "Hello world!"
    def self.cattr_accessor(*attributes)
      cattr_reader(*attributes)
      cattr_writer(*attributes)
    end

    ##
    # Append an attribute to the hidden attributes stack. Allow subclasses to
    # register attributes as secret. Thus, the value of these attributes aren't
    # visible outside of the class.
    def hide(attribute)
      unless attribute.respond_to? :to_s
        raise ArgumentException "#{self.class}##{method_id.to_s} expect a kind of string. #{attribute.class} given"
      end

      @@hidden_vars << "@#{attribute.to_s.gsub(/^@/, '')}".to_sym
      true
    end

    ##
    # Override the default behaviours by hiding attributes which run through
    # Class#hide method. Attributes which aren't stored into the stack of
    # hidden attributes are display as usual.
    def inspect
      attrs_nice_names = instance_variables.collect do |name|
        if @@hidden_vars.include? name
          " #{name}=\"******\""
        else
          " #{name}=#{instance_variable_get(name).inspect}"
        end
      end.compact.join(',')
      "#<#{self.class}:0x#{object_id}#{attrs_nice_names}>"
    end
  end
end
